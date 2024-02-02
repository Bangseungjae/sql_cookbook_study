# 문자열 작업

# 6.1 문자열 짚어보기
# 문자열에서의 각 문자를 행으로 반환하려고 하지만 SQL에는 루프 작업이 없습니다.
# 예를 들면 EMP 테이블의 ENAME인 'KING'을 4개 행으로 표시하려 합니다. 여기서 각 행은 KING의 문자만 포함합니다.

# 해법: 데카르트 곱을 사용하여 문자열의 각 문자를 각 행에 반환하는 데 필요한 수를 생성합니다.
# 그런 다음 RDBMS의 내장 문자열 구문 파싱 함수를 사용하여 관심 있는 문자를 추룰합니다.
select substr(e.ename, iter.pos, 1) as C
from (select ename from emp where ename = 'KING') e,
    (select id as pos from t10) iter
where iter.pos <= length(e.ename);
# substr(문자열, x번째 글자부터, y개)
# 설명: 문자열의 문자를 반복하는 핵심은 필요한 반복 횟수를 생성하기에 충분한 행이 있는 테이블과 조인하는 것입니다.
# 이 예제에서는 10개의 행을 포함하는 T10 테이블을 사용합니다(1에서 10까지의 값을 보유하는 하나의 ID열이 있습니다).
# 이 쿼리에서 반환할 수 있는 최대 행 수는 10개입니다.

# 다음은 ENAME을 파싱하지 않고 E와 ITER 사이 (즉, 특정 일므과 T10의 10개 행 사이)의 데카르트 곱을 보여줍니다.
select ename, iter.pos
from (select ename from emp where ename = 'KING') e,
     (select id as pos from t10) iter;

# 인라인 뷰 E의 카디널리티는 1이고 인라인 뷰 ITER의 카디널리티는 10입니다. 그러면 데카르트 곱은 10행입니다.
# 이런 식으로 행을 생성하는 것은 SQL에서 루프를 모방하는 첫 번째 단계입니다.
select ename, iter.pos
from (select ename from emp where ename = 'KING') e,
     (select id as pos from t10) iter
where iter.pos <= length(ename);

# 이제 E.ENAME에 대해 각 문자에 대해 행이 하나씩 있으므로 ITER.POS를 SUBSTR에 대한 매개변수로 사용하여
# 문자열의 문자를 탐색할 수 있습니다. ITER.POS는 행마다 증가하므로 E.ENAME에서 연속 문자를 반환하도록 각 행을 만들 수 있습니다.
# 예)
select substr(e.ename, iter.pos) a,
       substr(e.ename, length(e.ename)-iter.pos+1) b
from (select ename from emp where ename = 'KING') e,
     (select id as pos from t10) iter
where iter.pos <= length(ename);
# ===================================================================================

# 6.2 문자열에 따옴표 포함하기
select 'g''day mate' qmarks from t1 union all
select 'beavers''teeth' from t1;

# 6.3 문자열에서 특정 문자의 발생 횟수 계산하기
# 문제: 지정된 문자열 내에서 문자 또는 하위 문자열이 발생하는 횟수를 계산하려고 합니다. 다음 문자열을 살펴봅시다.
# 10,CLARK,MANAGER - 이 문자열에서 쉼표가 몇개 있는지 확인한다.
select (length('10,CLARK,MANAGER') - length(replace('10,CLARK,MANAGER',',',''))) / length(',') as cnt
from t1;

# 6.4 문자열에서 원하지 않는 문자 제거하기
# 데이터에서 특정 문자를 제거하려고 합니다. 이러한 상황은 잘못된 형식의 숫자 데이터, 특히 통화 데이터를 처리할 때 쉼표를 사용하여
# 0을 구분하거나, 수량과 통화 표기가 열에 혼합되는 경우 발생할 수 있습니다.
select ename,
       replace(
       replace(
       replace(
       replace(
       replace(ename, 'A', ''), 'E', ''), 'I', ''), 'O', ''), 'U', '') as stripped1,
    sal,
    replace(sal, 0, '') stripped2
from emp;

# 6.5 숫자 및 문자 데이터 분리하기
SELECT
    SUBSTRING(data, 1, LENGTH(data) - LENGTH(REGEXP_REPLACE(data, '^[a-zA-Z]*', ''))) AS letters,
    REGEXP_REPLACE(data, '^[a-zA-Z]*', '') AS numbers
FROM
    (select concat(ename, sal) data from emp) as ed;


# 6.6 문자열의 영숫자 여부 확인하기
# 관심 있는 열에 숫자와 문자 이외의 문자가 포함되지 않을 때만 테이블에서 행을 반환하려고 합니다.
create view V as
select ename as data
from emp
where deptno = 10
union all
select concat(ename,', $',cast(sal as char(4)),'.00')as data
from emp
where deptno = 20
union all
select concat(ename,cast(deptno as char(4)))as data
from emp
where deptno = 30;

select * from V;

drop view V;

# 위 데이터에서 문자열과 숫자만 있는 행을 반환하려고 할때
select * from V where data regexp '[^0-9-zA-Z]' = 0;
# ^기호는 부정을 의미하므로 숫자나 문자가 아님'을 의미한다. 반환값 1은 참이고 0은 거짓이므로
# 전체 표현식은 숫자와 문자 이외의 것을 반환한 행은 거짓임을 의미한다.

# 6.7 이름에서 이니셜 추출하기
# 전체 이름을 이니셜로 바꾸고 싶습니다. 다음 이름을 살펴봅시다.
# Stewie Griffin 이름을 다음과 같이 바꾸고자 합니다.
# S.G.
select case
    when cnt = 2 then
        trim(trailing '.' from concat_ws('.',
                                   substr(substring_index(name,' ',1),1,1),
                                   substr(name,
                                       length(substring_index(name,' ',1))+2, 1),
                                    '.'))
                      else
                        trim(trailing '.' from
                        concat_ws('.',
                        substr(substring_index(name, ' ', 1),1,1),
                        substr(substring_index(name, ' ',-1),1,1)
                        ))
                            end as initials
from (
    select name,length(name)-length(replace(name, ' ', '')) as cnt
    from (
        select replace('Stewie Griffin', '.', '') as name from t1
         ) y
     ) x;

# CONCAT_WS(구분자, 문자열1 [, 문자열2, 문자열3 ...])
# SUBSTRING_INDEX(문자열, 구분자, 구분자 Index)
# SUBSTRING(문자열, 시작 위치)
# SUBSTRING(문자열, 시작 위치, 시작 위치부터 가져올 문자수)
# SUBSTRING_INDEX 함수를 응용하면 JAVA의 split처럼 해당 index에 맞게 문자열을 추출할 수 있다
# SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(문자열, 구분자, 구분자 Index), 구분자, -1)
# SUBSTRING_INDEX() 함수는 문자열에서 지정한 구분자를 기준으로 하여 왼쪽부터 또는 오른쪽부터 특정 위치의 부분 문자열을 반환하는데 사용됩니다.
# 매개변수로 -1을 사용하면, 구분자를 기준으로 가장 오른쪽에 있는 부분 문자열을 반환합니다. 예를 들어, SUBSTRING_INDEX('OpenAI is cool', ' ', -1)의 결과는 'cool'이 됩니다.
# 따라서 SUBSTRING_INDEX(name, ' ', -1)라는 코드는 name이라는 필드의 값을 공백(' ')으로 분리하고, 가장 마지막 단어를 반환하게 됩니다. 이렇게 하면 마지막 이름이나, 주소의 마지막 부분 등을 쉽게 추출할 수 있습니다.


# 6.8 문자열 일부를 정렬하기
# 부분 문자열을 기준으로 결과셋을 정렬하려고 합니다. 다음 결과셋을 살펴봅시다.
select ename
from emp
order by substr(ename, length(ename)-1);

# 6.9 문자열을 숫자로 정렬하기
drop view V;

create view V as
    select concat(e.ename, ' ', cast(e.empno as char(4)), ' ', d.dname) as data
    from emp e, dept d
    where e.deptno=d.deptno;

select * from v;
# 이 때 사원명과 부서명 사이에 있는 사번을 기준으로 정렬하고 싶습니다.
# 방법: REPLACE 및 TRANSLATE 를 사용하여 문자열에서 숫자가 아닌 값을 제거하고 숫자만 남겨놓는다.
# MySQL은 TRANSLATE를 제공하지 않아서 실패..

# 6.10 테이블 행으로 구분된 목록 만들기
select deptno, group_concat(ename order by empno separator ',') as emps
from emp
group by deptno;

# 6.11 구분된 데이터를 다중값 IN 목록으로 변환하기
# 해법: 표면적으로는 SQL이 구분도니 문자열을 구분된 값의 목록으로 처리하는 작업을 해야 할 것처럼 보일 수 있지만 실제로는 그렇지
# 않습니다. 따옴표 안에 쉼표가 포함된 경우 SQL은 다중값 목록임을 알지 못합니다. SQL은 따옴표 사이에 모든 것을 하나의 문자열
# 값으로, 즉 단일 엔티티로 처리하여 하므로, 문자열을 개별 EMPNO로 나누어야 합니다. 이 해법의 핵심은 개별 문자가 아닌,
# 문자열로 이동하는 것입니다. 우리는 문자열을 유효한 EMPNO 값으로 이동하려고 합니다.
select empno, ename, sal, deptno
from emp
where empno in (
    select substring_index(
           substring_index(list.vals,',',iter.pos),',',-1
           ) empno
    from (select id as pos from t10) as iter,
         (select '7654,7698,7782,7788' as vals from t1) list
    where iter.pos <= (length(list.vals)-length(replace(list.vals, ',','')))+1
    );

    select
           substring_index(list.vals,',',-2)
            empno
    from (select id as pos from t10) as iter,
         (select '7654,7698,7782,7788' as vals from t1) list
    where iter.pos <= (length(list.vals)-length(replace(list.vals, ',','')))+1;