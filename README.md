## Elasticsearch zabbix 监控

### 使用方法

* zabbix_templates目录下的es_discovery.conf需要放置在/etc/zabbix/zabbix_agentd.d/目录下，如果zabbix自定义安装路径，则需要按照自己的部署路径调整

* zabbix_templates目录下的zbx_elasticsearch_templates.xml需要在zabbix的WEB操作页面下创建模板进行导入

* elasticsearch_mon目录下的文件需要放置到es_discovery.conf 文件指定的路径,如需更改，请同时更新es_discovery.conf 文件

>* 仅适用于Linux及Bash2.0+环境，Elasticsearch 5.0+版本测试可用，其他版本未经测试
>* 脚本依赖的JSON处理工具jq下载页面地址：https://stedolan.github.io/jq/,请下载jq后将其移动到系统的$PATH路径下
