import os

def replace_config(file_path, host, password):
    with open(file_path, 'r') as file:
        data = file.readlines()

    with open(file_path, 'w') as file:
        for line in data:
            if line.startswith('DBHost='):
                file.write(f'DBHost={host}\n')
            elif line.startswith('DBPassword='):
                file.write(f'DBPassword={password}\n')
            else:
                file.write(line)

if __name__ == "__main__":
    config_file = '/etc/zabbix/zabbix_server.conf'
    db_host = os.getenv('DB_HOST')
    db_password = os.getenv('DB_PASSWORD')

    if not db_host or not db_password:
        raise ValueError("Both DB_HOST and DB_PASSWORD environment variables must be set")

    replace_config(config_file, db_host, db_password)
