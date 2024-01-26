# 행 집합을 다른 행 위에 추가하기
# union all은 여러 행 소스의 행들을 하나의 결과셋으로 결합합니다.
select ename as ename_and_dname, deptno
from emp
where deptno = 10
union all
select '---------', null
from t1
union all
select dname, deptno
from dept;

select  deptno
from emp
union all
select deptno
from dept;
select * from DEPT;


# 연관된 여러 행 결합하기
select e.ename, d.loc
from emp e , dept d
where d.DEPTNO = 10
    and d.DEPTNO = e.DEPTNO;

# 대체 해법
select e.ename, d.loc
    from emp e inner join dept d
    on(e.deptno = d.deptno)
where e.deptno = 10;

# 두 테이블의 공통 행 찾기
create view V
as select ename, job, sal
from emp
where job = 'CLERK';

drop view V;

select * from V;

select e.empno, e.ename, e.job, e.sal, e.deptno
from emp e, V
where e.ename = v.ename
    and e.job = v.job
    and e.sal = v.sal;

# or

select e.empno, e.ename, e.job, e.sal, e.deptno
from emp e join V
    on(e.ename = v.ename
           and e.job = v.job
           and e.sal = v.sal
        );

# 한 테이블에서 다른 테이블에 존재하지 않는 값 검색하기
# EMP 테이블에서는 없는 DEPT 테이블의 부서 정보를 찾으려 한다
# DEPT 테이블의 DEPTNO 값이 40인 데이터는 EMP 테이블에는 없으므로 결과셋은 40이 나와야 한다.
# - 차집합 함수를 쓰면 쉽게 해결할 수 있다.
select deptno
from dept
where deptno not in (select deptno from emp);

# null 영향을 안받게 위와 동등한 쿼리를 날리면
select d.deptno
from dept d
where not exists(
    select 1
    from emp e
    where d.deptno = e.deptno
);

# 다른 테이블 행과 일치하지 않는 행 검색하기
# 사원이 없는 부서 찾기
select d.*
from dept d left outer join emp e
    on (d.deptno = e.deptno)
where e.deptno is null;

# 다른 조인을 방해하지 않고 쿼리에 조인 추가하기
# 모든 사원명(ENAME), 근무 부서의 위치(LOC) 및 보너스 받은 날짜(RECEIVED)를 반환하려고 합니다.
select * from emp_bonus;

create table emp_bonus(
    EMPNO int,
    RECEIVED varchar(100),
    TYPE int
);
insert emp_bonus values(7369, '14-MAR-2005', 1);
insert emp_bonus values(7900, '14-MAR-2005', 2);
insert emp_bonus values(7788, '14-MAR-2005', 3);

select e.ename, d.loc
from emp e, dept d
where e.deptno=d.deptno;
# 이 결과에 EMP_BONUS 테이블과 조인하며내 모든 사원이 보너스를 받은 것은 아니므로 원하는 수보다 적은 행을 반환합니다.
select e.ename, d.loc, eb.received
from emp e, dept d, emp_bonus eb
where e.deptno = d.deptno
    and e.empno = eb.empno;

# 해법 -> 외부 조인을 사용하여 원래 쿼리의 데이터의 손실 없이 추가 정보를 얻을 수 있다.
select e.ename, d.loc, eb.received
from emp e join dept d
    on(e.DEPTNO = d.DEPTNO)
left join emp_bonus eb
    on(e.EMPNO = eb.EMPNO)
order by 2;

# 스칼라 서브쿼리를 사용하여 외부 조인을 흉내 낼 수도 있다.
select e.ename, d.loc,
    (select eb.received from emp_bonus eb
        where eb.EMPNO = e.EMPNO) as received
from emp e, dept d
where e.deptno = d.deptno
order by 2;
# -------------------------------------------------------------------------------

# 두 테이블에 같은 데이터가 있는지 확인하기
# - 두 테이블 또는 뷰에 같은 데이터(카디널리티 및 값)가 있는지 알고 싶습니다.
create view V
as
    select * from emp where deptno != 10
union all
select * from emp where ename = 'WARD';

select * from V;

# 카디널리티가 같으면 하나의 행만 반환된다.
select count(*)
from emp
union
select count(*)
from dept;

select *
from (
    select e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno, count(*) as cnt
    from emp e
    group by e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno
     ) e
where not exists(
    select null
from (
    select v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno, count(*) as cnt
    from V v
    group by v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno
     ) as v
where v.empno = e.empno
  and v.ename = e.ename
  and v.job = e.job
  and v.mgr = e.mgr
  and v.hiredate = e.hiredate
  and v.sal = e.sal
  and v.deptno = e.deptno
  and v.cnt = e.cnt
  and coalesce(v.comm, 0) = coalesce(e.comm, 0)
);

select null
from (
    select v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno, count(*) as cnt
    from V v
    group by v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno
     ) as v2;

select v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno, count(*) as cnt
from V v
group by v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno;
# ----------------------------------------------------------------------------------

# 데카르트 곱 식별 및 방지하기
select e.ename, d.loc
from emp e, dept d
where e.deptno = 10
    and d.deptno = e.deptno;

# ----------

# 집계를 사용할 때 조인 수행하기

SELECT * FROM emp_bonus;

INSERT emp_bonus VALUES(7934, '17-MAR-2005', 1);
INSERT emp_bonus VALUES(7934, '15-FEB-2005', 2);
INSERT emp_bonus VALUES(7839, '15-FEB-2005', 3);
INSERT emp_bonus VALUES(7782, '15-FEB-2005', 1);

select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type = 1 then .1
                                  when eb.type = 2 then .2
                                  else .3
                        end as bonus
from emp e, emp_bonus eb
where e.empno = eb.empno
    and e.deptno = 10;
# 지금까지는 순조롭다 그러나 보너스 금액을 합산하고자 emp_bonus 테이블에 조인하려면 문제가 생긴다.

select deptno, sum(sal) as total_sal, sum(bonus) as total_bonus
from (
    select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type = 1 then .1
                                  when eb.type = 2 then .2
                                  else .3
                        end as bonus
from emp e, emp_bonus eb
where e.empno = eb.empno
    and e.deptno = 10
     ) x
group by deptno;
# TOTAL_SAL의 올바른 값은 8750 이다. 위 쿼리는 잘못된 값이 나온다.
# 이유는 sal 열의 중복 행 때문이다.
select sum(sal)
from emp
where deptno = 10;

# 합산하는 열에 중복되는 값이 있을 때 필요한 대체 해법
# 급여 합계가 먼제 계산되고 그 행을 EMP 테이블에 조인한 다음 EMP_BONUS 테이블에 조인합니다.
select d.deptno,
       d.total_sal,
       sum(e.sal*case when eb.type = 1 then .1
                      when eb.type = 2 then .2
                      else .3 end) as total_bonus
from emp e, emp_bonus eb, (
    select deptno, sum(sal) as total_sal
    from emp
    where deptno = 10
    group by deptno
) d
where e.deptno = d.deptno
    and e.empno = eb.empno
group by d.deptno, d.total_sal;


select deptno, sum(sal) as total_sal
from emp
where deptno = 10
group by deptno;

# -------------------------------------------------------------------

# 집계 시 외부 조인 수행하기
select * from emp_bonus;

delete from emp_bonus
where empno = 7782;

select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type is null then 0
                  when eb.type = 1 then .1
                  when eb.type = 2 then .2
                  else .3 end as bonus
from emp e left join emp_bonus eb
    on (e.EMPNO = eb.EMPNO)
where e.deptno = 10;

select deptno,
       sum(distinct sal) as total_sal,
       sum(bonus) as total_bonus
from (
    select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type is null then 0
                  when eb.type = 1 then .1
                  when eb.type = 2 then .2
                  else .3 end as bonus
from emp e left join emp_bonus eb
    on (e.EMPNO = eb.EMPNO)
where e.deptno = 10
     ) x
group by deptno;

select d.deptno,
       d.total_sal,
       sum(
               e.sal*case when eb.type = 1 then .1
                          when eb.type = 2 then .2
                          else .3 end
       ) as total_bonus
from emp e,
     emp_bonus eb,
     (
         select deptno, sum(sal) as total_sal
         from emp
         where deptno = 10
         group by deptno
     ) d
where e.deptno = d.deptno
    and e.empno = eb.empno
group by d.deptno, d.total_sal;


# 여러 테이블에서 누락된 데이터 반환하기
select d.deptno,d.dname, e.ename
from dept d left outer join emp e
on(d.deptno = e.deptno);

# => 부서가 없는 사원이 있을 때
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
select 1111, 'YODA', 'JEDI', null, hiredate, sal, comm, null
from emp
where ename = 'KING';

select d.deptno, d.dname, e.ename
from dept d right outer join emp e
    on (d.deptno=e.deptno);
# 이 외부 조인은 새 사원을 반환하지만, 원래 결과셋에서 OPERATOINS 부서가 누락되었습니다.
# 해법 FULL OUTER JOIN, MySQl은  full outer join이 아직 없어서 union을 써야한다.
select d.deptno, d.dname, e.ename
from dept d right outer join emp e
    on (d.deptno=e.deptno)
union
select d.deptno, d.dname, e.ename
from dept d left outer join emp e
    on (d.deptno=e.deptno);

# --------------------------------------------------------------------

# 연산 및 비교에서 null 사용하기
# 문제 커미션(COMM)이 사원 워드(WORD)의 커미션보다 적은 모든 사원을 EMP 테이블에서 찾으려고 한다.
# 이때 커미션이 null인 사원도 포함해야 한다.
select ename, comm, coalesce(comm, 0)
from emp
where coalesce(comm, 0) < (select comm
                           from emp
                           where ename = 'WARD');