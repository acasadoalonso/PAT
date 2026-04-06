#!/bash
cp    patServer/docker-compose.yaml .
cp    patServer/realm-config.json .
cp -r patServer/grafana .
git add .
git commit
git push origin master
