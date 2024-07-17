#!/bin/bash

# 기본 변수 입력 받기
read -p "Storage Type (nfs or hostPath): " STORAGE_TYPE
read -p "Name for PV and PVC: " NAME
read -p "StorageClass: " STORAGE_CLASS
read -p "Storage Size (e.g. 1Gi): " STORAGE_SIZE
read -p "YAML 파일 저장 경로 (기본: 현재 디렉토리): " YAML_PATH

# YAML_PATH가 비어있으면 현재 디렉토리로 설정
YAML_PATH=${YAML_PATH:-$(pwd)}

# Storage Type에 따른 추가 정보 입력 받기
if [ "$STORAGE_TYPE" == "nfs" ]; then
    read -p "NFS Server IP: " NFS_SERVER
    read -p "NFS Path: " NFS_PATH
elif [ "$STORAGE_TYPE" == "hostPath" ]; then
    read -p "Host Path: " HOST_PATH
else
    echo "지원되지 않는 storage type입니다. 'nfs' 또는 'hostPath'를 선택해주세요."
    exit 1
fi

# PV YAML 생성
create_pv_yaml() {
    local pv_file="${YAML_PATH}/${NAME}-pv.yaml"
    if [ "$STORAGE_TYPE" == "nfs" ]; then
        cat <<EOF > "$pv_file"
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $NAME
spec:
  capacity:
    storage: $STORAGE_SIZE
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: $STORAGE_CLASS
  nfs:
    server: $NFS_SERVER
    path: "$NFS_PATH"
EOF
    elif [ "$STORAGE_TYPE" == "hostPath" ]; then
        cat <<EOF > "$pv_file"
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $NAME
spec:
  capacity:
    storage: $STORAGE_SIZE
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: $STORAGE_CLASS
  hostPath:
    path: "$HOST_PATH"
    type: DirectoryOrCreate
EOF
    fi
    echo "PV YAML 파일이 생성되었습니다: $pv_file"
}

# PVC YAML 생성
create_pvc_yaml() {
    local pvc_file="${YAML_PATH}/${NAME}-pvc.yaml"
    cat <<EOF > "$pvc_file"
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $NAME
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: $STORAGE_SIZE
  storageClassName: $STORAGE_CLASS
EOF
    echo "PVC YAML 파일이 생성되었습니다: $pvc_file"
}

# YAML 파일 생성 실행
create_pv_yaml
create_pvc_yaml

echo "PV와 PVC YAML 파일이 $YAML_PATH 경로에 성공적으로 생성되었습니다."
echo "생성된 YAML 파일을 검토한 후, 다음 명령어로 적용할 수 있습니다:"
echo "kubectl apply -f ${YAML_PATH}/${NAME}-pv.yaml"
echo "kubectl apply -f ${YAML_PATH}/${NAME}-pvc.yaml"