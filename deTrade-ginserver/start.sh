# 启动vue架构,将构建的dist目录复制到后端
cd ../deTrade-front
npm run build


cd ../deTrade-ginserver
rm -rf dist
cp -r ../deTrade-front/dist dist

cat <<EOF

前端页面构建完成

EOF

# 编译当前目录下的Go程序
go build -o detrade
# 启动后端，&后台运行
./detrade 
