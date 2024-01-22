# SQL-injection

## 공격

```sh
    ## SQL Injection
    ' OR 1=1 #
```

![sql](../public/sql.png)
![sql-2](../public/sql-2.png)

## WAF에서는 어떻게 뜰까?

- 사실 코드단에서도 막긴 막아야 함
- 하지만 임시로 WAF에서 막아보자...

![sql-acl-1](../public/sql-acl-1.png)
![sql-acl-2](../public/sql-acl-2.png)

## 결과

![sql-acl-3](../public/sql-acl-3.png)
![sql-acl-4](../public/sql-acl-4.png)

-
