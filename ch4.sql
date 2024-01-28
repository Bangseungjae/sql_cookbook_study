### 삽입, 갱신, 삭제

show tables;

show databases;

use cook_book;

# 새로운 레코드 삽입하기
insert into dept (deptno, dname, loc)
values (50, 'PROGRAMMING', 'BALTIMORE');

/* 여러 행 삽입 */
insert into dept (deptno, dname, loc)
values (1, 'A', 'B'),
       (2, 'B', 'C');

select * from dept;

# 기본값 삽입하기
create table D (
    id integer default 0
);

insert into D values (default);
# or
insert into D (id) values (default);
# or
insert into D values();

select * from D;

# null로 오바라이딩 하기
drop table D;

create table D (
    id integer default 0,
    foo VARCHAR(10)
);

insert into d (id, foo) values (null, 'Brighten');

select * from d;

# 한 테이블에서 다른 테이블로 행 복사하기
select * from dept;

create table dept_east (
    DEPTNO integer,
    DNAME varchar(40),
    LOC varchar(30)
);

insert into dept_east (deptno, dname, loc)
select deptno, dname, loc
from dept
where loc in ('NEW YORK', 'BOSTON');

select * from dept_east;

# 테이블 정의 복사하기
# 기존 테이블과 같은 열 집합을 가지는 새 테이블을 만들려고 합니다.
# 이 때 행은 복사하지 않고 열 구조만 복사하려고 합니다.
create table dept_2 like dept;
# or
create table dept_3
as
    select *
    from dept
    where 1 = 0;

select * from dept_2;
select * from dept_3;

# 특정 열에 대한 삽입 차단하기
# ex) 프로그램이 EMP 테이블에 값을 삽입하도록 허용하되 EMPNO, ENAME 및 JOB열에만 삽입하도록 합니다.

# 해법 : 테이블에 표시할 열만 노출하는 뷰를 만듭니다. 그런 다음 모든 삽입 내용이 해당 뷰를 통과하도록 합니다.
create view new_emps as
    select empno, ename, job
    from emp;
# 뷰에 있는 세 개의 필드만 채울 수 있도록 허용된 사용자 및 프로그램에, 이 뷰에 대한 엑세스 권한을 부여합니다.
# 이들 사용자에게 EMP 테이블에 대한 삽입 권한은 부여하지 마세요.

# 아래 해법에서는 단순 뷰에 삽입하면 데이터베이스 서버는 삽입 내용을 기본 테이블로 변환합니다.
insert into new_emps
    (empno, ename, job)
values (1, 'Jonathan', 'Editor');
# 아래와 같이 변환된다.
insert into emp
    (empno, ename, job)
values (1, 'Jonathan', 'Editor');
# 단순한 뷰를 제외하면 뷰에 삽입하는 기능은 매우 복잡하다. 뷰에 삽입하는 기능을 사용하려면 해당 문제에 관해 벤더 문서를 참조해야함.
select *
from emp;
### --------------------------------------------------------------------

# 테이블에서 레코드 수정하기
# ex) 부서 20에 속한 모든 사원의 급여를 10% 인상
select deptno, ename, sal
from emp
where deptno = 20
order by deptno, sal;
# 여기서 10% 인상을 하려고 한다.
# 해법
update emp
set sal = sal*1.10
where deptno = 20;

# 대량의 업데이트를 준비할 때 결과를 미리 볼 수도 있다.
select deptno,
       ename,
       sal as orig_sal,
       sal*.10 as amt_to_add,
       sal*1.10 as new_sal
from emp
where deptno = 20
order by deptno, new_sal;
# -----------------------------------------------------------

# 일치하는 행이 있을 때 업데이트 하기
# ex) emp_bonus 테이블에 사원 정보가 있다면 EMP 테이블의 해당 사원 급여를 20% 인상하려고 합니다.
# 다음 결과셋은 emp_bonus 데이터이다.
select *
from emp_bonus;
# 해법
update emp
    set sal=sal*1.20
where empno in (select empno from emp_bonus);
# or
update emp
set sal = sal*1.20
where exists (select null
              from emp_bonus
              where emp.empno=emp_bonus.empno);

select empno,
       sal as origin,
       sal*.20 as amt_to_add,
       sal*1.20 as new_sal
from emp
where exists(
    select null
    from emp_bonus
    where emp_bonus.EMPNO=emp.EMPNO
);

# 다른 테이블 값으로 업데이트
create table new_sal(
    DEPTNO integer,
    SAL integer
);

insert into new_sal (DEPTNO, SAL) values (10, 4000);

update emp e, new_sal ns
set e.sal = ns.sal,
    e.comm = ns.sal/2
where e.deptno=ns.deptno;

select * from emp
where emp.deptno;

# 레코드 병합하기
# 해당하는 레코드가 있는지 여부에 따라 조건부로 테이블의 레코드를 삽입, 업데이트 또는 삭제할 수 있습니다.
# - EMP_COMMISSION의 사원이 EMP 테이블에 있을 때, 해당 사원의(COMM)을 1,000으로 업데이트합니다.
# - COMM을 1,000으로 업데이트할 가능성이 있는 모든 사원에 대해, SAL이 2,000미만이면 해당 사원을 삭제합니다.(EMP_COMMISSION이 존재하지 않아야 합니다.)
# 그렇지 않으면 EMP 테이블의 EMPNO, ENAME, DEPTNO 값을 EMP_COMMISSION 테이블에 삽입합니다.

select deptno, ename, comm
from emp
order by 1;

create table emp_commission(
    DEPTNO integer,
    EMPNO integer,
    ENAME varchar(50),
    COMM integer
);

insert into emp_commission
values
    (10, 7782, 'CLARK', null),
    (10, 7839, 'KING', null),
    (10, 7934, 'MILLER', null);
select * from emp_commission;

# MySQL에서는 Merge 문이 없어서 불가...
# ------------------------------------------------------------

# 테이블에서 모든 레코드 삭제하기
delete from emp;

# 특정 레코드 삭제하기
delete from emp where deptno = 10;

# 단일 레코드 삭제하기
delete from emp where empno = 7782;

# 참조 무결성 위반 삭제하기
# ex) 일부 사원이 현재 존재하지 않는 부서에 할당되었을 때 해당 사원을 삭제하려고 합니다.
delete from emp
where not exists(
    select * from dept
    where dept.deptno=emp.deptno
);
# or
delete from emp
where deptno not in (select deptno from dept);

select * from emp;

# 중복 레코드 삭제하기
create table dupes(id integer, name varchar(10));

insert into dupes
values
    (1, 'NAPOLEON'),
    (2, 'DYNAMITE'),
    (3, 'DYNAMITE'),
    (4, 'SHE SELLS'),
    (5, 'SHE SELLS'),
    (6, 'SHE SELLS'),
    (7, 'SHE SELLS');

select * from dupes;

drop table dupes;

delete from dupes
where id not in (
    select min(id)
    from (
        select id, name from dupes
         ) tmp
    group by name
    );

delete from dupes
where id not in (
    select min(id)
    from dupes as d
    group by name
);

# -------------------------------------------

# 다른 테이블에서 참조된 레코드 삭제하기
create table dept_accidents(
    deptno integer,
    acident_name varchar(20)
);

insert into dept_accidents
values
    (10, 'BROKEN FOOT'),
    (10, 'FLESH WOUND'),
    (20, 'FIRE'),
    (20, 'FIRE'),
    (20, 'FLOOD'),
    (30, 'BRUISED GLUTE');

select * from dept_accidents;

# 여기서 잡계함수 COUNT를 사용하여 세 번 이상 사고가 발생한 부서를 찾습니다.
# 그런 다음 해당 부서에서 일하는 모든 사원을 삭제합니다.
delete from emp
where deptno in (
    select deptno
    from dept_accidents
    group by deptno
    having count(*) >= 3
    );

## 3번 이상 사고가 발생한 부서 찾기
select deptno
from dept_accidents
group by deptno
having count(*) >= 3;