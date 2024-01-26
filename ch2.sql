# 지정한 순서대로 쿼리 결과 반환하기
select ename, job, sal
from emp
where deptno = 10
order by sal asc;

# 지정한 순서대로 쿼리 결과 반환하기
# 부서 10에 속한 사원명, 직책 및 급여를 급여 순서대로 표시
select ename, job, sal
from emp
where deptno = 10
order by sal asc;

# 다중 필드로 정렬하기
# EMP 테이블에서 DEPTNO 기준 오름차순으로 정렬한 다음, 급여(SAL) 내림차순으로 정렬
select empno, deptno, sal, ename, job
from emp
order by deptno asc, sal desc;

# 부분 문자열로 정렬하기
# EMP 테이블에서 사원명과 직급을 반환하되 JOB열의 마지막 두 문자를 기준으로 정렬
select ename, job
from emp
order by substr(job, length(job) - 1);

# 혼합 영숫자 데이터 정렬하기
# 데이터의 숫자 또는 문자 부분을 기준으로 정렬하려고 한다 EMP 테이블에서 만든 다음 뷰를 살펴보자
create view V
as
    select concat(ename, '  ', deptno) as data
    from emp;

select * from V;


select concat(ename, '  ', deptno) as data
from emp
order by deptno desc;

# 정렬할 때 null 처리하기
# EMP 테이블의 결과를 COMM 기준으로 정렬하려고 할 때, 필드가 null을 허용합니다.
# 이 때 null을 마지막에 정렬할지를 지정하는 방법이 필요
select ename,sal,comm, is_null
from (
     select ename, sal, comm,
     case when comm is null then 0 else 1 end as is_null
     from emp
     ) x
order by is_null desc, comm;

# 데이터 종속 키 기준으로 정렬하기
# 일부 조건식을 기반을 정렬, 예를 들어 JOB이 'SALESMAN'이면 COMM 기준으로 정렬하고, 그렇지 않으면 SAL 기준으로 정렬
select ename,sal,job,comm
from emp
order by case when job = 'SALESMAN' then comm else sal end;

select ename,sal,job,comm,
       IF(job = 'SALESMAN', comm, sal) as ordered
from emp
order by ordered;