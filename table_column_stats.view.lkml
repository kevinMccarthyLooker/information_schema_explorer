
#since different column's stats may give different row counts for the table, this rollup is used for row table's row count, for use when totalling across multiple tables.
view: table_column_stats__table_rows {
  derived_table: {
#     sql:
#       SELECT
#       schemaname,
#       tablename,
#       max(table_approximate_row_count) as table_approximate_row_count
#       from ${table_column_stats.SQL_TABLE_NAME}
#       group by 1,2
#       ;;
  sql:
  SELECT pg_namespace.nspname as table_schema,relname as table_name,reltuples as approximate_row_count
  FROM pg_class
  left join pg_namespace on pg_class.relnamespace=pg_namespace.oid
  ;;
}

dimension: table_schema {}
dimension: table_name {}
dimension: primary_key__table_schema__table_name {primary_key:yes hidden:yes sql:${table_schema}||${table_name};;}

#   dimension: schemaname {}
#   dimension: tablename {}
#   dimension: primary_key_tablename_schemaname {primary_key:yes sql:${schemaname}||${tablename};;}
dimension: approximate_row_count {type:number}
measure: total_table_rows {
  label: "Row Count (approx.)"
  description: "sum of approximate row count for included tables, based on system table estimates which can be out of date and should always be double checked"
  type: sum
#     sql: ${table_approximate_row_count} ;;
  sql: ${TABLE}.approximate_row_count ;;

}
}


### Main Column Stats table
#get statistics from several system stats table
view: table_column_stats {
  derived_table: {
    sql: with t as
      (
      SELECT
      schemaname,
      tablename,
      attname,
      pg_stats.n_distinct,
      case when n_distinct>0 then n_distinct else null end as approximate_values_count,
      case when n_distinct<0 then n_distinct*-1 else null end as distinct_values_over_rows,
      case when n_distinct<0 then (1+n_distinct) else null end as percent_repeat_values,
      -- most_common_vals,
      -- array_to_string(most_common_vals,','),
      --must be a better way to parse the top value
      replace(left(array_to_string(most_common_vals,','),charindex(',',array_to_string(most_common_vals,','))),',','') as common_value1,
      most_common_freqs[1] as common_value1_frequency_percent
      -- ,most_common_freqs[2]
      FROM pg_catalog.pg_stats
      --where tablename='subscriptions'
      -- group by most_common_freqs
      -- order by most_common_freqs[1]

          where
          {% condition information_schema__columns.table_name %}tablename{% endcondition %}
          and
          {% condition information_schema__columns.column_name %}attname{% endcondition %}
      ),
      row_count as
      (
      SELECT relname,relam, reltuples as approximate_row_count FROM pg_class
      )
      select
      t.schemaname,
      t.tablename,
      t.attname,
      -- t.approximate_values_count,
      -- floor(distinct_values_over_rows*approximate_row_count) as approximate_values_count2,
      coalesce(t.approximate_values_count,floor(distinct_values_over_rows*approximate_row_count)) as approximate_values_count,
      coalesce(t.approximate_values_count,floor(distinct_values_over_rows*approximate_row_count))/approximate_row_count as percent_non_repeated,
      1-coalesce(t.approximate_values_count,floor(distinct_values_over_rows*approximate_row_count))/approximate_row_count as percent_repeated,
      -- t.percent_repeat_values,
      common_value1,
      common_value1_frequency_percent,
      approximate_row_count as table_approximate_row_count


      from t left join row_count on t.tablename=row_count.relname
      order by common_value1_frequency_percent

      -- —approximate row count by table:
      -- SELECT relname,relam, reltuples as approximate_row_count FROM pg_class
       ;;
  }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }
  dimension: primary_key_field {sql:${schemaname}||${tablename}||${attname};; primary_key:yes}

  dimension: schemaname {
    type: string
    sql: {{ _view._name | replace: '_hidden_fields','' }}.schemaname ;;
  }

  dimension: tablename {
    type: string
    sql: {{ _view._name | replace: '_hidden_fields','' }}.tablename ;;
  }

  dimension: attname {
    type: string
    sql: {{ _view._name | replace: '_hidden_fields','' }}.attname ;;
  }

  dimension: approximate_values_count {
    type: number
    sql: {{ _view._name | replace: '_hidden_fields','' }}.approximate_values_count ;;
  }

  dimension: percent_non_repeated {
    type: number
    sql: {{ _view._name | replace: '_hidden_fields','' }}.percent_non_repeated ;;
    value_format_name: percent_2
  }

  dimension: percent_repeated {
    type: number
    sql: {{ _view._name | replace: '_hidden_fields','' }}.percent_repeated ;;
    value_format_name: percent_2
  }

  dimension: common_value1 {
    type: string
    sql: {{ _view._name | replace: '_hidden_fields','' }}.common_value1 ;;
  }

  dimension: common_value1_frequency_percent {
    type: number
    sql: {{ _view._name | replace: '_hidden_fields','' }}.common_value1_frequency_percent ;;
    value_format_name: percent_2
  }

#moved to table_column_stats__table_rows
#   dimension: table_approximate_row_count {
# #     hidden: yes
#     type: number
#     sql: {{ _view._name | replace: '_hidden_fields','' }}.table_approximate_row_count ;;
#   }

#   measure: total_table_rows {
#     description: "sum of approximate row count for included tables"
#     type: sum_distinct
#     sql_distinct_key: ${schemaname}||${tablename} ;;
#     sql: ${table_approximate_row_count} ;;
#   }


#
#
#   set: detail {
#     fields: [
#       schemaname,
#       tablename,
#       attname,
#       approximate_values_count,
#       percent_non_repeated,
#       percent_repeated,
#       common_value1,
#       common_value1_frequency_percent,
#       table_approximate_row_count
#     ]
#   }
  set: hidden_fields {fields:[attname,primary_key_field,schemaname,tablename]}
}
view: table_column_stats_hidden_fields {extends: [table_column_stats]}
