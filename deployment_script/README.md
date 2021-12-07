## Overview

Creates rds postgres instance, Deploys node/angular application for qms in docker container

### Execution

1. ./build.sh <base_url> <git_private_key_encrypted_s3_path> <env_file_encrypted_s3_path> <kms_key> 

    # base_url: http://localhost
    
    # git_private_key_encrypted_s3_path: s3://panasonic-qms/secrets/id_rsa.git_key.encrypted
    
    # env_file_encrypted_s3_path: s3://panasonic-qms/secrets/env.secrets.encrypted
    
    # kms_key: 2312331-6630-473d-9926-5b403sfd3423
        
        
        
        
        