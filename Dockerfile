# 精确锁定 0.6.5 镜像层
#FROM cloakhq/cloakbrowser@sha256:d25e539dd029d899734aa6e2a706ccc7fa4014cc5654dc07cb5afcfe1048c4e9
FROM cloakhq/cloakbrowser:latest

# 固定缓存路径（仅保留防止被 HOME=/github/home 覆盖的必要变量）
ENV XDG_CACHE_HOME=/opt/cache \
    CLOAKBROWSER_WIDEVINE_CDM=/root/WidevineCdm \
    DISPLAY=:99

# 1. 预装系统依赖并清理 apt 缓存
RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
        zip unzip xauth python3-tk python3-dev git && \
    rm -rf /var/lib/apt/lists/*

# 2. 预装 Windows 字体
COPY fonts/ /usr/share/fonts/windows/
RUN fc-cache -f

# 3. 一步完成 Widevine 插件、cloakbrowser[geoip]==0.6.5 离线包与 v146 内核的固化
RUN python /usr/local/bin/fetch-widevine.py --out /root/WidevineCdm && \
    mkdir -p /opt/wheels /opt/cache && \
    pip download "cloakbrowser[geoip]==0.6.5" -d /opt/wheels && \
    pip install --no-index --find-links=/opt/wheels "cloakbrowser[geoip]==0.6.5"

RUN python -c "from cloakbrowser import ensure_binary; ensure_binary()"