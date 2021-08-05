
This repo has 2 terraform modules.
# [tf1](https://github.com/IdontApply/fl-maytham-1/tree/main/tf1) 

This module consistes of:
- 1 s3 instance.
- 1 ec2 instance.
  
<p>Both resources should be tagged correctly, to test that run the following command in the test folder/path:</p>

```console
go test -v -timeout 15m -run TestTf1
```
Info on deployment will be found here [tf1](https://github.com/IdontApply/fl-maytham-1/tree/main/tf1).

# [tf2](https://github.com/IdontApply/fl-maytham-1/tree/main/tf2) 

This module consistes of mainly of:
- 1 vpc
- 2 ec2 instances.
- 1 alb.
<p>This module sets up alb that serves static files, located on 2 ec2 instances running nginx</p> 
<p>Static files should be reachable through alb, to test that run the following command in the test folder/path:</p>

```console
go test -v -timeout 15m -run TestTf2
```
Info on deployment will be found here [tf2](https://github.com/IdontApply/fl-maytham-1/tree/main/tf2).
