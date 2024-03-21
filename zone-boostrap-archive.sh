export DOMAIN=${DOMAIN:-"example.com"}
export RGWREGION=${RGWREGION:-"default"}
export RGWZONE=${RGWZONE:-"default"}
export RGWPORT=${RGWPORT:-80}
export RGWMASTER=${RGWMASTER:-"east-rgw"}

ceph config set global mon_allow_pool_delete true
for id in alertmanager grafana prometheus ; do ceph orch rm ${id} ; done

sleep 10

radosgw-admin realm pull --url=http://${RGWMASTER}.${DOMAIN}:${RGWPORT} --access-key=eastwestrepl --secret=eastwestrepl123456789
radosgw-admin realm default --rgw-realm=${RGWREGION}
radosgw-admin zone create --rgw-zonegroup=${RGWREGION} --rgw-zone=${RGWZONE} --access-key=eastwestrepl --secret=eastwestrepl123456789  --endpoints=http://${RGWZONE}-rgw.${DOMAIN}:${RGWPORT} --tier-type=archive

echo "Waiting 60 seconds to settle zone creation"
sleep 60

radosgw-admin zone delete --rgw-zone=default

for x in default.rgw.log default.rgw.control default.rgw.meta ; do ceph osd pool rm ${x} ${x} --yes-i-really-really-mean-it ; done

sleep 10

radosgw-admin period update --commit

ceph config set client.rgw rgw_zone ${RGWZONE}
ceph orch restart rgw.default.${RGWZONE}
