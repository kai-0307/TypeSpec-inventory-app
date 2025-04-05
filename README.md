## TypeSpec

https://typespec.io/

## 出力

```shell
npx tsp compile service1.tsp --emit @typespec/openapi3
```

## Dockerを使ってSwagger UIを起動する

```shell
docker run -p 8080:8080 -e SWAGGER_JSON=/foo/stock-api.yaml -v $(pwd)/tsp-output/@typespec/openapi3:/foo swaggerapi/swagger-ui
```

上記コマンド実行後、ブラウザで http://localhost:8080 にアクセスすると、生成されたAPI仕様がSwagger UIで表示されます。

## モックサーバーを使いたい場合

```shell
npm install -g @stoplight/prism-cli
prism mock tsp-output/@typespec/openapi3/stock-api.yaml
```
