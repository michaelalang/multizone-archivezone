export CEPHIP=$(ip -br a | awk '/eth0/ { print $3 }' | cut -f1 -d'/')
export RGWHOST=$(hostname)
export RGWREGION=${RGWREGION:-"default"}
export RGWZONE=${RGWZONE:-"default"}
export RGWPORT=${RGWPORT:-80}

cat rollout-tmpl.yml | envsubst > rollout.yml

cephadm bootstrap \
	--mon-ip ${CEPHIP} \
	--initial-dashboard-user admin \
	--initial-dashboard-password changeme \
	--ssh-private-key /home/cephadmin/.ssh/id_rsa \
	--ssh-public-key /home/cephadmin/.ssh/id_rsa.pub \
	--ssh-user cephadmin \
	--dashboard-password-noupdate \
	--allow-fqdn-hostname \
	--allow-overwrite \
	--apply-spec /root/rollout.yml \
	--single-host-defaults

