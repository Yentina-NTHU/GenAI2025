import pandas as pd 
import numpy as np
from functools import reduce
from scipy.stats import entropy
import boto3
import os
from autogluon.tabular import TabularPredictor
from sklearn.model_selection import train_test_split
# 設定 S3
s3 = boto3.client('s3',
    aws_access_key_id='',
    aws_secret_access_key=''
)
bucket_name = 'detectorbucket01'


def read_train_data_from_S3():
    # 指定 bucket 和 object key
    s3.download_file(bucket_name, 'upload/train/train_account_info.csv', './train_account_info.csv')
    s3.download_file(bucket_name, 'upload/train/train_customer_info.csv', './train_customer_info.csv')
    s3.download_file(bucket_name, 'upload/train/train_account_transactions.csv', './train_account_transactions.csv')
    s3.download_file(bucket_name, 'upload/train/train_suspicious_accounts.csv','./train_suspicious_accounts.csv')
    print("✅ train_account_info.csv 下載成功！")
    account_info = pd.read_csv('./train_account_info.csv')
    customer_info = pd.read_csv('./train_customer_info.csv')
    transactions = pd.read_csv('./train_account_transactions.csv')
    suspicious = pd.read_csv('./train_suspicious_accounts.csv')
    return account_info,  customer_info,  transactions, suspicious

def read_test_data_from_S3():
    s3.download_file(bucket_name, 'upload/test/test_account_info.csv', './test_account_info.csv')
    s3.download_file(bucket_name, 'upload/test/test_customer_info.csv', './test_customer_info.csv')
    s3.download_file(bucket_name, 'upload/test/test_account_transactions.csv', './test_account_transactions.csv')
    print("✅ test_account_info.csv 下載成功！")
    account_info = pd.read_csv('./test_account_info.csv')
    customer_info = pd.read_csv('./test_customer_info.csv')
    transactions = pd.read_csv('./test_account_transactions.csv')
    return account_info,  customer_info,  transactions


def data_preprocess(mode, account_info,  customer_info,  transactions, suspicious):
    # === 2. 型別一致化 ===
    account_info['account_number'] = account_info['account_number'].astype(str)
    customer_info['customer_id'] = customer_info['customer_id'].astype(str)
    transactions['account_number'] = transactions['account_number'].astype(str)
    transactions['counterparty_account'] = transactions['counterparty_account'].astype(str)
    
    # === 3. 合併主檔 ===
    merged = pd.merge(account_info, customer_info, on='customer_id', how='left')
    
    # === 4. 基本交易特徵 ===
    in_df = transactions[transactions['transaction_direction'] == 1]
    out_df = transactions[transactions['transaction_direction'] == 0]
    
    total_in = in_df.groupby('account_number')['transaction_amount'].sum().reset_index(name='total_amount_in')
    total_out = out_df.groupby('account_number')['transaction_amount'].sum().reset_index(name='total_amount_out')
    avg_in = in_df.groupby('account_number')['transaction_amount'].mean().reset_index(name='avg_amount_in')
    avg_out = out_df.groupby('account_number')['transaction_amount'].mean().reset_index(name='avg_amount_out')
    count_df = transactions.groupby('account_number')['transaction_amount'].count().reset_index(name='num_transactions')
    
    minmax = transactions.groupby('account_number')['transaction_amount'].agg(
        max_transaction_amount='max',
        min_transaction_amount='min'
    ).reset_index()
    
    has_in = total_in.assign(had_incoming_transaction=1)[['account_number', 'had_incoming_transaction']]
    has_out = total_out.assign(had_outgoing_transaction=1)[['account_number', 'had_outgoing_transaction']]
    
    n_channels = transactions.groupby('account_number')['transaction_channel'].nunique().reset_index(name='n_unique_transaction_channels')
    n_branches = transactions.groupby('account_number')['branch_number'].nunique().reset_index(name='n_unique_branch_numbers')
    n_targets = transactions.groupby('account_number')['counterparty_account'].nunique().reset_index(name='n_unique_target_accounts')
    
    # === 5. 群組統計特徵（不含 one-hot）===
    tx_code_group_dict = {
        '現金存提類': [1, 4, 7, 18, 24, 25, 29, 30],
        '轉帳交易類': [2, 3, 10, 11, 12, 14, 15, 20, 26, 27, 28, 42, 44],
        '授權與利息類': [6, 13, 16, 17, 51],
        '票據相關類': [8, 9, 19, 52, 53, 54],
        '繳費與費用類': [31, 35, 46, 48, 49, 50],
        '消費與退貨類': [32, 33, 34, 39, 45, 47],
        '沖正與異常處理類': [5, 21, 22, 23, 36, 37, 38, 40, 41, 43],
        '其他或特殊轉帳類': [19]
    }
    
    group_tx_list = []
    for group_name, codes in tx_code_group_dict.items():
        group_df = transactions[transactions['transaction_code'].isin(codes)].groupby('account_number').agg({
            'transaction_amount': ['count', 'sum']
        })
        group_df.columns = [f'tx_grp_{group_name}_count', f'tx_grp_{group_name}_amount']
        group_df = group_df.reset_index()
        group_tx_list.append(group_df)
    
    group_tx_agg = reduce(lambda left, right: pd.merge(left, right, on='account_number', how='outer'), group_tx_list).fillna(0)
    
    # === 6. 五個進階特徵 ===
    in_out = pd.merge(total_in, total_out, on='account_number', how='outer').fillna(0)
    in_out['in_out_ratio'] = in_out['total_amount_in'] / (in_out['total_amount_out'] + 1)
    in_out = in_out[['account_number', 'in_out_ratio']]
    
    high_thresh = transactions['transaction_amount'].quantile(0.9)
    high_tx_ratio = transactions.groupby('account_number').apply(
        lambda x: (x['transaction_amount'] > high_thresh).sum() / len(x)
    ).reset_index(name='high_amount_ratio')
    
    transactions['transaction_date'] = pd.to_datetime(transactions['transaction_date'])
    n_days = transactions.groupby('account_number')['transaction_date'].nunique().reset_index(name='n_active_days')
    
    avg_gap = transactions.sort_values(['account_number', 'transaction_date']).groupby('account_number')['transaction_date'].apply(
        lambda x: np.mean(np.diff(x).astype('timedelta64[D]')) if len(x) > 1 else 0
    ).reset_index(name='avg_days_between_tx')
    avg_gap['avg_days_between_tx'] = avg_gap['avg_days_between_tx'].astype(float)
    
    def tx_entropy(x):
        counts = x['transaction_code'].value_counts()
        return entropy(counts / counts.sum())
    
    entropy_tx = transactions.groupby('account_number').apply(tx_entropy).reset_index(name='entropy_tx_code')
    
    # === 7. 三個交互特徵 ===
    entropy_thresh = entropy_tx['entropy_tx_code'].median()
    high_amount_thresh = high_tx_ratio['high_amount_ratio'].median()
    
    high_amount_and_entropy = pd.merge(high_tx_ratio, entropy_tx, on='account_number')
    high_amount_and_entropy['high_amount_and_entropy'] = (
        (high_amount_and_entropy['high_amount_ratio'] > high_amount_thresh) &
        (high_amount_and_entropy['entropy_tx_code'] > entropy_thresh)
    ).astype(int)
    high_amount_and_entropy = high_amount_and_entropy[['account_number', 'high_amount_and_entropy']]
    
    is_digital_and_active = pd.merge(account_info[['account_number', 'is_digital_account']], n_days, on='account_number')
    is_digital_and_active['is_digital_and_active'] = (
        (is_digital_and_active['is_digital_account'] == 1) &
        (is_digital_and_active['n_active_days'] > 10)
    ).astype(int)
    is_digital_and_active = is_digital_and_active[['account_number', 'is_digital_and_active']]
    
    many_branches_and_tx = pd.merge(n_branches, count_df, on='account_number')
    many_branches_and_tx['many_branches_and_tx'] = (
        (many_branches_and_tx['n_unique_branch_numbers'] >= 5) &
        (many_branches_and_tx['num_transactions'] >= 100)
    ).astype(int)
    many_branches_and_tx = many_branches_and_tx[['account_number', 'many_branches_and_tx']]
    
    # === 8. 近 7 天時間序列特徵 ===
    latest_date = transactions['transaction_date'].max()
    recent_7day_tx = transactions[transactions['transaction_date'] >= latest_date - pd.Timedelta(days=7)]
    recent_7day_count = recent_7day_tx.groupby('account_number')['transaction_amount'].count().reset_index(name='recent_7day_tx_count')
    recent_7day_avg = recent_7day_tx.groupby('account_number')['transaction_amount'].mean().reset_index(name='recent_7day_avg_amt')
    
    # === 9. 合併所有特徵（無 one-hot）===
    tx_features = [
        total_in, total_out, avg_in, avg_out, count_df, minmax,
        has_in, has_out, n_channels, n_branches, n_targets,
        in_out, high_tx_ratio, n_days, avg_gap, entropy_tx,
        high_amount_and_entropy, is_digital_and_active, many_branches_and_tx,
        recent_7day_count, recent_7day_avg, group_tx_agg
    ]
    
    tx_merged = reduce(lambda left, right: pd.merge(left, right, on='account_number', how='outer'), tx_features).fillna(0)
    
    # === 10. 合併回主資料 ===
    final_train = pd.merge(merged, tx_merged, on='account_number', how='left').fillna(0)
    print(len(final_train.columns))
    if mode == "train":
        # 建立標籤欄位，代表此帳戶是否為可疑帳戶
        suspicious['is_suspicious'] = 1
        
        # 合併標籤進主資料（依據 account_number）
        final_train = pd.merge(final_train, suspicious[['account_number', 'is_suspicious']], on='account_number', how='left')
        
        # 對於未出現在警示名單中的帳戶，標記為 0（非可疑）
        final_train['is_suspicious'] = final_train['is_suspicious'].fillna(0).astype(int)
    
    final_train.to_csv('./customer__account_info_trans_without_onehot.csv', index=False)
    local_file_path = './customer__account_info_trans_without_onehot.csv'
    if mode == "train":
        s3_object_key = 'upload/train/train_customer__account_info_trans_without_onehot.csv'
        s3.upload_file(local_file_path, bucket_name, s3_object_key)
        print("✅ 上傳成功！")
        os.remove('./train_account_info.csv')
        os.remove('./train_customer_info.csv')
        os.remove('./train_account_transactions.csv')
        os.remove('./train_suspicious_accounts.csv')
    elif mode == "test":
        s3_object_key = 'upload/test/test_customer__account_info_trans_without_onehot.csv'
        s3.upload_file(local_file_path, bucket_name, s3_object_key)
        print("✅ 上傳成功！")
        os.remove('./test_account_info.csv')
        os.remove('./test_customer_info.csv')
        os.remove('./test_account_transactions.csv')
    else:
        print("Wrong Mode!")

import shutil

def zip_folder(folder_path, output_zip_path):
    shutil.make_archive(output_zip_path, 'zip', folder_path)
    print(f"✅ 已壓縮資料夾：{folder_path} → {output_zip_path}.zip")

import zipfile
import os

def unzip_model(zip_path, extract_to='./autogluon_model'):
    os.makedirs(extract_to, exist_ok=True)
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)
    print(f"✅ 已解壓縮到：{extract_to}")


def upload_file_to_s3(file_path, bucket_name, s3_key):
    s3.upload_file(file_path, bucket_name, s3_key)
    print(f"✅ 已上傳 {file_path} → s3://{bucket_name}/{s3_key}")

def download_model_zip(bucket_name, s3_key, local_path):
    s3.download_file(bucket_name, s3_key, local_path)
    print(f"✅ 模型 zip 已下載：{local_path}")  

    

def train_process():
    # account_info,  customer_info,  transactions, suspicious = read_train_data_from_S3()
    # data_preprocess("train",account_info,  customer_info,  transactions, suspicious)
    # s3.download_file(bucket_name, 'upload/train/train_customer__account_info_trans_without_onehot.csv', './train_customer__account_info_trans_without_onehot.csv')
    # print("下載完成")
    # df = pd.read_csv('./train_customer__account_info_trans_without_onehot.csv')
    # # 清除所有含有 NaN 的列（會影響約 2,000 筆）
    # df_cleaned = df.dropna()

    
    # # 儲存清理後資料（可選）
    # df_cleaned.to_csv('./data/Train/train_customer__account_info_trans_without_onehot_cleaned.csv', index=False)

    # # 檢查剩下筆數與是否有缺失
    # print(f"原始筆數: {df.shape[0]}")
    # print(f"清理後筆數: {df_cleaned.shape[0]}")
    # print("剩餘缺失值總數:", df_cleaned.isna().sum().sum())

    
    
    # # 讀資料
    
    # # 切分訓練 / 驗證集
    # train_df, val_df = train_test_split(df_cleaned, test_size=0.2, stratify=df_cleaned['is_suspicious'], random_state=42)
    
    # # 訓練 AutoGluon
    # predictor = TabularPredictor(label='is_suspicious', eval_metric='f1', path='./autogluon_model') \
    #     .fit(train_data=train_df, tuning_data=val_df, time_limit=600)
    # print("訓練完成!")
    zip_folder('./autogluon_model', './autogluon_model_backup')
    upload_file_to_s3('./autogluon_model_backup.zip','detectorbucket01', 'upload/autogluon_model_backup.zip')
    
def test_process():
    account_info,  customer_info,  transactions = read_test_data_from_S3()
    data_preprocess("test",account_info,  customer_info,  transactions, suspicious = None)
    s3.download_file(bucket_name, 'upload/test/test_customer__account_info_trans_without_onehot.csv', './test_customer__account_info_trans_without_onehot.csv')
    print("下載完成")
    # 清除所有含有 NaN 的列（會影響約 2,000 筆）
    df = pd.read_csv('./test_customer__account_info_trans_without_onehot.csv')
    df_clean = df.dropna()
    
    # 儲存清理後資料（可選）
    df.to_csv('./test_customer__account_info_trans_without_onehot.csv', index=False)
    
    # 檢查剩下筆數與是否有缺失
    print(f"原始筆數: {df.shape[0]}")
    print(f"清理後筆數: {df_clean.shape[0]}")
    print("剩餘缺失值總數:", df_clean.isna().sum().sum())

    download_model_zip(bucket_name='detectorbucket01', s3_key='upload/autogluon_model_backup.zip',  local_path='./autogluon_model_backup.zip')
    unzip_model('./autogluon_model_backup.zip', './autogluon_model_test')

    predictor = TabularPredictor.load('./autogluon_model_test')
    # 預測
    test_pred = predictor.predict(df_clean)
    
    # 結合帳號與預測結果
    submission = df_clean[['account_number']].copy()
    submission['is_suspicious'] = test_pred
    
    # 將預測為 0 的項目設為空白
    submission['is_suspicious'] = submission['is_suspicious'].apply(lambda x: 1 if x == 1 else '')
    
    # 儲存為比賽要求格式
    submission.to_csv('./submission_TEST.csv', index=False)
    s3_object_key = 'upload/submission_TEST.csv'
    s3.upload_file('./submission_TEST.csv', bucket_name, s3_object_key)
    print("✅ 上傳成功！")
    
if __name__ == "__main__":
   # train_process()
   test_process()