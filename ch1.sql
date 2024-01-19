select *
from emp;

# 테이블에서 행의 하위 집합 검색하기
select * from EMP
where DEPTNO = 10;

# 여러 조건을 충족하는 행 찾기
select * from EMP
where (DEPTNO = 10
    or COMM is not null
    or SAL <= 2000 and DEPTNO = 20
          )
    and DEPTNO=20;

# 테이블에서 열의 하위 집합 검색하기
select ENAME, DEPTNO, SAL
from emp;

# 열에 의미있는 이름 지정하기
select SAL as salary, COMM as commission
from EMP;