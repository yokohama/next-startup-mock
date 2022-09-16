# Welcome to Next Startup Mock

## Dependencies

### github actionsのsecretsに、awsクレデンシャルを設定
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

### API Gatewayの名前の設定
- 先に、[NextStartupCDK](http://https://github.com/yokohama/next-startup-cdk)をセットアップする必要が有ります。
- 上記を実行すると、APIGatewayが各環境（local, dev, prod）に作成されます。
![範囲を選択_420](https://user-images.githubusercontent.com/1023421/190696565-39b529a0-ba65-4c31-aec1-b2dd4d00ef4a.png)

- [local](https://github.com/yokohama/next-startup-mock/blob/development/openapi/root-local.yaml)と、[dev](https://github.com/yokohama/next-startup-mock/blob/development/openapi/root-dev.yaml)と、[prod](https://github.com/yokohama/next-startup-mock/blob/development/openapi/root-prod.yaml)の、３つのファイルのtitleを上記で作成された各APIの名前に変更して下さい。

この部分

![範囲を選択_421](https://user-images.githubusercontent.com/1023421/190698563-bd7edd50-ef62-4342-8c5c-f257ce8525c9.png)


## Deploy

### local（APIGatewayの、NextStartUpApi-local）
- ローカルコンソールより実行
```
bash ./bin/deploy.sh
```

### dev（APIGatewayの、NextStartUpApi-dev）
- developmentブランチにマージ

### prod（APIGatewayの、NextStartUpApi-prod）
- mainブランチにマージ
