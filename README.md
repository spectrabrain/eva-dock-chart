# EVA-Dock Helm Chart

이 차트는 EVA-Dock 백엔드와 영구 데이터 볼륨을 배포합니다. Ingress 생성은 선택이며,
기존 Ingress를 쓸 때는 `ingress.enabled=false`로 두고 차트 Service의 80번 포트로 연결합니다.

## 기본 구성

- ECR 이미지: `values.yaml`의 `image.repository`와 `image.tag`
- ConfigMap: 일반 설정을 컨테이너 환경변수로 전달
- Kubernetes Secret: 비밀번호, MySQL 자격증명 등 민감 환경변수 전달
- PVC: SQLite DB(`/data/eva_live.db`)에 알림 이력, 카메라 카탈로그, EVA 등록 정보와 화면 정책을 보존
- Service: 클러스터 내부 HTTP 80번 포트
- Ingress: 선택 생성. 기존 Ingress를 사용하면 비활성 상태로 둡니다.

SQLite를 한 파일에 쓰므로 기본 replica 수는 1입니다. 이 차트는 Caddy를 배포하지 않으며,
TLS 종료는 Ingress가 담당하는 구성을 기본으로 합니다. EVA-Dock은 `/`와 `/api/...` 경로를
사용하므로 Ingress에서는 전용 호스트 사용을 권장합니다.

## 앱 민감값

초기 설치에서는 `values.yaml`의 다음 항목을 입력하면 차트가 Kubernetes Secret을 만들고
컨테이너 환경변수로 전달합니다.

```yaml
secrets:
  dockAccessPassword: "Dock 로그인 비밀번호"
  evaMysqlUser: ""
  evaMysqlPassword: ""
```

MySQL 계정은 feedback 조회를 DB로 설정한 경우에만 필요합니다. 기존 Secret을 쓰려면
`secrets.existingSecret`에 이름을 지정할 수 있습니다.

## ECR 이미지 pull (NKS)

ECR 이미지 pull 인증은 앱 민감값 Secret과 별도입니다. NKS에서 사용할 ECR Docker 인증 Secret을
같은 namespace에 만들고, `values.yaml`의 `imagePullSecrets`에 이름을 지정합니다.

```yaml
imagePullSecrets:
  - name: ecr-pull-secret
```

ECR 로그인 토큰은 12시간 후 만료되므로, 장기 운영 시 토큰을 자동 갱신하는 구성이 필요합니다.

## 설치 예시

다음 명령으로 설치합니다. NKS의 ECR pull Secret은 별도로 생성해야 합니다.

```sh
helm upgrade --install eva-dock ./deploy/helm/eva-dock \
  --namespace eva-dock --create-namespace \
  --set imagePullSecrets[0].name=ecr-pull-secret
```

이미지 태그, 기능 플래그, PVC 크기, Ingress 옵션은 `values.yaml` 또는 별도 환경별 values 파일로
조정합니다. 기존 Ingress를 쓸 때는 해당 Ingress의 backend를 배포된 Service의 80번 포트로
지정하면 됩니다. SSE와 MJPEG 스트림 경로는 장시간 연결을 허용하도록 Ingress를 설정해야 합니다.
