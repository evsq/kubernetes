# Usage

```
kubectl apply -f fio.yaml
kubectl exec -it NAMEFIOPOD -- bash
fio --name=test --filename=/data/testfile --filesize=10G --time_based --ramp_time=2s --runtime=1m --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 --bs=4k --iodepth=4096 --rw=write --group_reporting
fio --name=test --filename=/data/testfile --filesize=10G --runtime=1m --ioengine=libaio --direct=1 --bs=4k --iodepth=32 --rw=randwrite --buffered=0
```