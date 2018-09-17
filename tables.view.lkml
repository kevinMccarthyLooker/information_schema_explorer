view: tables {
  derived_table: {
    sql:
    select tables.* ,table_summary.column_count
    from information_schema.tables
    left join
    (
        select
        table_catalog:: varchar as table_catalog,
        table_schema:: varchar as table_schema,
        table_name:: varchar as table_name,
        count(*) as column_count
        from information_schema.columns
        group by 1,2,3
    ) table_summary
    on  tables.table_catalog=table_summary.table_catalog
    and tables.table_schema=table_summary.table_schema
    and tables.table_name=table_summary.table_name
    left join
    (
    select
    schemaname,
    tablename,
    max(case when distkey=true then pg_table_def.column else null end) as distkey
    from pg_table_def
    group by schemaname,
    tablename
    )table_summary2
    on
    --tables.table_catalog=table_summary2.table_catalog
    --and
    tables.table_schema=table_summary2.schemaname
    and tables.table_name=table_summary2.tablename


    where table_summary.table_schema<>'information_schema' and table_summary.table_schema<>'pg_catalog'
        ;;
  }
  dimension: primary_key {primary_key:yes sql:${table_catalog}||${table_schema}||${table_name};;}
  dimension: table_catalog {}
  dimension: table_schema {}
  dimension: table_name {}
  dimension: column_count {}
  measure: total_tables_count {type:count}
  measure: total_column_count {type:sum sql:${column_count};;}
}
