# k8s-network-tshoot
collection of scripts, yamls and other resources for troubleshooting networking on Kubernetes


```bash
kubectl exec -it -n kube-system $(CILIUM_AGENT_POD) -- bpftool net show
Defaulted container "cilium-agent" out of: cilium-agent, config (init), mount-cgroup (init), apply-sysctl-overwrites (init), mount-bpf-fs (init), clean-cilium-state (init), install-cni-binaries (init)
xdp:
 
tc:
cilium_net(2) clsact/ingress cil_to_host-cilium_net id 1209
cilium_host(3) clsact/ingress cil_to_host-cilium_host id 1184
cilium_host(3) clsact/egress cil_from_host-cilium_host id 1197
cilium_vxlan(4) clsact/ingress cil_from_overlay-cilium_vxlan id 1154
cilium_vxlan(4) clsact/egress cil_to_overlay-cilium_vxlan id 1155
lxc_health(6) clsact/ingress cil_from_container-lxc_health id 1295
eth0(7) clsact/ingress cil_from_netdev-eth0 id 1223
lxc4a891387ff1a(9) clsact/ingress cil_from_container-lxc4a891387ff1a id 1285
lxc5b7b34955e61(11) clsact/ingress cil_from_container-lxc5b7b34955e61 id 1303
lxc73d2e1d7cf4(13) clsact/ingress cil_from_container-lxc73d2e1d7cf4 id 1294
```

Hex representation of IPv4 Address

```bash
printf '%02X' 192 168 1 128 ; echo
```
