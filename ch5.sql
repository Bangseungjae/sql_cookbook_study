show databases;

use blog_platform;

show tables;

# 해당 장에서는 데모를 위해 cook_book 이라는 스키마가 있다고 가정합니다.

create table SMEAGOL(
    SMEAGOL_ID integer,
    name varchar(30)
);

# 특정 스키마에서 생성한 모든 테이블 목록을 보고자 합니다.
select table_name
from information_schema.tables
where table_schema = 'cook_book';


# 테이블의 열 나열하기
select column_name, data_type
from information_schema.columns
where table_schema = 'blog_platform' and table_name = 'blog_category';

# 테이블의 인덱싱된 열 나열하기
# 특정 테이블의 인덱스에서 인덱스 색인, 해당 열 및 열 위치(가능한 경우)를 나열하려고 합니다.
show index from cook_book.emp;

# 테이블의 제약조건 나열하기
# 일부 스키마의 테이블에 대해 정의된 제약조건과, 해당 제약 조건이 정의된 열을 나열하려고 합니다.
# 예를 들어 EMP 테이블에 대한 제약조건 및 해당 제약조건이 있는 열을 찾으려고 합니다.
select a.table_name,
       a.constraint_name,
       b.column_name,
       a.constraint_type
from information_schema.table_constraints a,
     information_schema.key_column_usage b
where a.table_name = 'blog'
    and a.table_schema = 'blog_platform'
    and a.table_name = b.table_name
    and a.table_schema = b.table_schema
    and a.constraint_name = b.constraint_name;


# 관련 인덱스가 없는 외래 키 나열하기
# 인덱싱되지 않은 외래 키 열을 가진 테이블을 나열하려고 합니다.
show index from cook_book.emp;

# MySQL은 5버전 이후 외래키가 자동으로 인덱싱된다.
# show index랑 비교해서 show 인덱스에는 없지만 아래 쿼리에는 나오는 컬럼 이름이 있으면 인덱싱 되지 않은 것이다.
select a.TABLE_NAME, a.COLUMN_NAME
from information_schema.KEY_COLUMN_USAGE a
where a.TABLE_NAME = 'EMP';

# SQL로 SQL 생성하기
# 유지 관리 작업을자동화하고자 동적 SQL 문을 생성하려 합니다.
# 1) 테이블의 행 수를 계산한 다음,
# 2) 테이블에 정의된 외래 키 제약조건을 비활성화하고,
# 3) 테이블의 데이터에서 삽입 스크립트를 생성하는 세 가지 작업을 수행하려고 합니다.

# 문자열을 써서 SQL 문을 작성한다는 개념으로, 입력할 값은 선택한 테이블의 데이터에 의해 제공됩니다.
# select 'select (count(*) from '||t.table_name||';' cnts
select concat('count(*) from ', t.TABLE_NAME, ';') cnts
from information_schema.TABLES t
where t.TABLE_SCHEMA = 'cook_book';

/* 모든 테이블의 외래 키를 비활성화하기 */
select concat('alter table', table_name, ' disable constraint ', constraint_name, ';') cons
from information_schema.table_constraints
where CONSTRAINT_TYPE = 'PRIMARY KEY';

/* EMP 테이블의 일부 열에 삽입하는 스크립트 생성하기 */
select concat('insert into emp(empno, ename, hiredate) ', CHAR(10), 'values(',
       empno, ',',ename, ',', hiredate,');')
from emp
where deptno=10;

