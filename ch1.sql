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

# WHERE 절에서 별칭이 지정된 열 참조하기
select *
from (
         select SAL as salary, COMM as commission
         from emp
     ) x
where salary < 5000;


# 열 값 이어 붙이기 해법
select concat(ENAME, ' WORKS AS A ', JOB) as msg
from emp
where deptno = 10;

# SELECT 문에서 조건식 사용하기
select ENAME, SAL,
    case when SAL <= 2000 then 'UNDERPAID'
         when SAL >= 4000 then 'OVERPAID'
         else 'OK'
    end as status
from EMP;

# 반환되는 행 수 제한하기
select *
from EMP
limit 5;

# 테이블에서 n개의 무작위 레코드 반환하기
select ENAME, JOB
from EMP
order by rand() limit 5;

# null 값 찾기
select *
from EMP
where COMM is null;

# null을 실젯값으로 변환하기
# null일 경우 0을 반환하고 아니면 실젯값을 반환
select coalesce(COMM, 0)
from EMP;

select case
    when COMM is not null then COMM
    else 0
    end as real_comm
from EMP;
# ---------------------------------------

# 패턴 검색하기
select ENAME, JOB
from EMP
where DEPTNO in (10, 20);

# 부서 10과 20의 사원들 중 이름에 'I'가 있거나 직급명이 'ER'로 끝나는 사원만 반환
select ename, job
from emp
where deptno in (10, 20)
    and (ename like "%I%" or job like "%ER");

# -------------------------------------------------


