FROM mapway/builder:3.0 as builder
WORKDIR /worker
ARG PULL_PASSWORD
RUN  . ~/.bashrc \
     && git clone --depth=1 https://zhangjianshe:$PULL_PASSWORD@codeup.aliyun.com/60a6145d44816b8ed2332594/biz-common.git  \
     && cd biz-common \
     && mvn clean package install -Dmaven.test.skip=true -ntp \
     && cd ..  \
     && git clone --depth=1 https://zhangjianshe:$PULL_PASSWORD@codeup.aliyun.com/60a6145d44816b8ed2332594/satway/cis-im.git \
     && cd cis-im \
     && chmod +x ./im && ./im package \
     && cd ..  \
     && git clone --depth=1 https://zhangjianshe:$PULL_PASSWORD@codeup.aliyun.com/60a6145d44816b8ed2332594/mapway-gwt-suit.git  \
     && cd mapway-gwt-suit \
     && mvn clean package install -Dmaven.test.skip=true -ntp \
     && cd ..  \
     && git clone --depth=1 https://zhangjianshe:$PULL_PASSWORD@codeup.aliyun.com/60a6145d44816b8ed2332594/cis.git  \
     && cd cis && chmod +x ./build.sh 

RUN  cd /worker/cis && ./build.sh  
 


FROM mapway/gdal-base:3.0 as cis-map
WORKDIR /app
COPY --from=builder /worker/cis/cis-map/target/cis-map-1.0.0.jar app.jar
CMD ["java","-XX:+UnlockExperimentalVMOptions", "-XX:+UseContainerSupport", "-jar", "app.jar"]

FROM mapway/gdal-base:3.0 as cis-k8s
WORKDIR /app
COPY --from=builder /worker/cis/cis-k8s/target/cis-k8s-1.0.0.jar app.jar
CMD ["java","-XX:+UnlockExperimentalVMOptions", "-XX:+UseContainerSupport", "-jar", "app.jar"]

FROM mapway/gdal-base:3.0 as cis-server  
WORKDIR /app
COPY --from=builder /worker/cis/cis-server/target/cis-server-1.0.0.jar app.jar
CMD ["java","-XX:+UnlockExperimentalVMOptions", "-XX:+UseContainerSupport", "-jar", "app.jar"]



     