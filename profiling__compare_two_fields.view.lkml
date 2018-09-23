include: "columns_basic*"
view: profiling__compare_two_fields {
  derived_table: {
    sql: -- -- Check two fields against one another for key relationship
      select
      COMPARE_Table_Name||'.'||COMPARE_Column_Name||'='||COMPARE_TO_table_name||'.'||COMPARE_TO_Column_Name as sql_on,
      case
        when one_to_one=1 then 'one_to_one'
        when many_to_many=1 then 'many_to_many'
        when one_to_many=1 then 'one_to_many'
        when many_to_one=1 then 'many_to_one'
        else 'unknown'
      end as relationsip,
      case
        when Distinct_Values_On_COMPARE_Only>0 and Distinct_Values_On_COMPARE_TO_Only>0 then 'full_outer'
        when Distinct_Values_On_COMPARE_Only>0 and Distinct_Values_On_COMPARE_TO_Only=0 then 'left_outer'
        when Distinct_Values_On_COMPARE_Only=0 and Distinct_Values_On_COMPARE_TO_Only>0 then 'right_outer'
        when Distinct_Values_On_COMPARE_Only=0 and Distinct_Values_On_COMPARE_TO_Only=0 then 'inner'
        else 'unknown'
      end as join_type,
      case
        when many_to_many=1 then 'many_to_many'
        when field_unique_on_COMPARE=1 then COMPARE_Table_Name||'.'||COMPARE_Column_Name||' is unique'
        when field_unique_on_COMPARE_TO=1 then COMPARE_TO_table_name||'.'||COMPARE_TO_Column_Name||' is unique'
        else 'n/a'
      end as message,


      *

      from

      (
      select
      max(COMPARE_Table_Name) as COMPARE_Table_Name,
      max(COMPARE_Column_Name) as COMPARE_Column_Name,
      max(COMPARE_TO_table_name) as COMPARE_TO_table_name,
      max(COMPARE_TO_Column_Name) as COMPARE_TO_Column_Name,

      min(case when (COMPARE_Row_Count>1 or COMPARE_TO_Row_Count>1) and field is not null then 0 else 1 end) as one_to_one,
      max(case when COMPARE_Row_Count>1 and COMPARE_TO_Row_Count>1 and field is not null then 1 else 0 end) as many_to_many,
      max(case when COMPARE_Row_Count<=1 and COMPARE_TO_Row_Count>1 and field is not null then 1 else 0 end) as one_to_many,
      max(case when COMPARE_Row_Count>1 and COMPARE_TO_Row_Count<=1 and field is not null then 1 else 0 end) as many_to_one,

      case when max(COMPARE_Row_Count)=1 then 1 else 0 end as field_unique_on_COMPARE,
      sum(case when COMPARE_found_on_table= 1 then COMPARE_Row_Count else 0 end) as total_rows_on_COMPARE,
      sum(case when COMPARE_found_on_table= 1 then 1 else 0 end) as count_distinct_values_on_COMPARE,
      sum(case when COMPARE_found_on_table= 1 then 1 else 0 end)*1.0/nullif(sum(case when COMPARE_found_on_table= 1 then COMPARE_Row_Count else 0 end),0) as percent_distinct_on_COMPARE,

      case when max(COMPARE_TO_Row_Count)=1 then 1 else 0 end as field_unique_on_COMPARE_TO,
      sum(case when COMPARE_TO_found_on_table= 1 then COMPARE_TO_Row_Count else 0 end) as total_rows_on_COMPARE_TO,
      sum(case when COMPARE_TO_found_on_table= 1 then 1 else 0 end) as count_distinct_values_on_COMPARE_TO,
      sum(case when COMPARE_TO_found_on_table= 1 then 1 else 0 end)*1.0/nullif(sum(case when COMPARE_TO_found_on_table= 1 then COMPARE_TO_Row_Count else 0 end),0) as percent_distinct_on_COMPARE_TO,


      sum(case when COMPARE_found_on_table= 1 and COMPARE_TO_found_on_table=0 then 1 else 0 end) as Distinct_Values_On_COMPARE_Only,
      sum(case when COMPARE_found_on_table= 1 and COMPARE_TO_found_on_table=1 then 1 else 0 end) as Distinct_Values_On_Both,
      sum(case when COMPARE_found_on_table= 0 and COMPARE_TO_found_on_table=1 then 1 else 0 end) as Distinct_Values_On_COMPARE_TO_Only,

      sum(COMPARE_Row_Count) as COMPARE_Row_Count,
      sum(COMPARE_TO_Row_Count) as COMPARE_TO_Row_Count
      -- ,
      -- sum(row_count) as total_table_rows
      from
      (
      select

      field,
      max(case when which_table='table1' then table_name else null end) as COMPARE_Table_Name,
      max(case when which_table='table2' then table_name else null end) as COMPARE_TO_table_name,
      max(case when which_table='table1' then column_name else null end) as COMPARE_Column_Name,
      max(case when which_table='table2' then column_name else null end) as COMPARE_TO_Column_Name,

      sum(case when which_table='table1' and field is not null then 1 else 0 end) COMPARE_found_on_table,
      sum(case when which_table='table1' then row_count else 0 end) COMPARE_Row_Count,
      sum(case when which_table='table2'  and field is not null then 1 else 0 end) COMPARE_TO_found_on_table,
      sum(case when which_table='table2' then row_count else 0 end) COMPARE_TO_Row_Count

      from
      (
      /*COMPARE Field*/
      select '{% parameter compare_table_name_input_parameter %}' as table_name,'{% parameter compare_field_name_input_parameter %}' as column_name,{% parameter compare_field_name_input_parameter %} as field,'table1' as which_table,count(*) as row_count
      from {% parameter compare_table_name_input_parameter %}
      /*where field is not null*/
      group by 1,2,3,4
      union all
      /*COMPARE_TO Field*/
      select '{% parameter compare_to_table_name_input_parameter %}' as table_name,'{% parameter compare_to_field_name_input_parameter %}' as column_name,{% parameter compare_to_field_name_input_parameter %} as field,'table2' as which_table,count(*) as row_count
      from {% parameter compare_to_table_name_input_parameter %}
      /*where field is not null*/
      group by 1,2,3,4
      )t2
      group by 1
      )t3
      )t4
       ;;
  }

  parameter: compare_table_name_input_parameter {
    type: unquoted
    suggest_explore: columns_basic
    suggest_dimension: columns_basic.table_name
  }

  parameter: compare_field_name_input_parameter {
    type: unquoted
    suggest_explore: columns_basic
    suggest_dimension: columns_basic.column_name
  }

  parameter: compare_to_table_name_input_parameter {
    type: unquoted
    suggest_explore: columns_basic
    suggest_dimension: columns_basic.table_name
  }

  parameter: compare_to_field_name_input_parameter {
    type: unquoted
    suggest_explore: columns_basic
    suggest_dimension: columns_basic.column_name
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: sql_on {
    type: string
    sql: ${TABLE}.sql_on ;;
  }

  dimension: relationsip {
    type: string
    sql: ${TABLE}.relationsip ;;
  }

  dimension: join_type {
    type: string
    sql: ${TABLE}.join_type ;;
  }

  dimension: join_type_no_right_outer {
    type: string
#     sql: ${TABLE}.join_type ;;
    case: {
      when: {sql:${join_type}='left_outer' or ${distinct_values_on_compare_to_only}=0;; label:"left_outer"}
      when: {sql:${join_type}='inner';; label:"inner"}
      when: {sql:${join_type} in ('full_outer','right_outer');; label:"full_outer"}

    }
  }

  dimension: message {
    type: string
    sql: ${TABLE}.message ;;
  }

  dimension: compare_table_name {
    type: string
    sql: ${TABLE}.compare_table_name ;;
  }

  dimension: compare_column_name {
    type: string
    sql: ${TABLE}.compare_column_name ;;
  }

  dimension: compare_to_table_name {
    type: string
    sql: ${TABLE}.compare_to_table_name ;;
  }

  dimension: compare_to_column_name {
    type: string
    sql: ${TABLE}.compare_to_column_name ;;
  }

  dimension: many_to_many {
    type: number
    sql: ${TABLE}.many_to_many ;;
  }

  dimension: one_to_many {
    type: number
    sql: ${TABLE}.one_to_many ;;
  }

  dimension: many_to_one {
    type: number
    sql: ${TABLE}.many_to_one ;;
  }

  dimension: field_unique_on_COMPARE {
    type: number
    sql: ${TABLE}.field_unique_on_COMPARE ;;
  }

  dimension: has_duplicates_on_COMPARE {
    type: yesno
    sql: field_unique_on_COMPARE=0 ;;
    html: {% if value == 'Yes' %}<p style="color: black; background-color: rgb(255,240,240); font-size:100%">Yes (aka MANY)</p>{% else %}<p style="color: black; background-color: rgb(180,255,180); font-size:100%">No (aka ONE)</p>{% endif %} ;;
  }

  dimension: total_rows_on_compare {
    label: "Not Null Rows on Compare"
    type: number
    sql: ${TABLE}.total_rows_on_compare ;;
  }

  dimension: count_distinct_values_on_compare {
    type: number
    sql: ${TABLE}.count_distinct_values_on_compare ;;
  }

  dimension: percent_distinct_on_compare {
    type: number
    sql: ${TABLE}.percent_distinct_on_compare ;;
    value_format_name: percent_1
  }

  dimension: field_unique_on_COMPARE_TO {
    type: number
    sql: ${TABLE}.field_unique_on_COMPARE_TO ;;
  }

  dimension: has_duplicates_on_COMPARE_TO {
    type: yesno
    sql: field_unique_on_COMPARE_TO=0 ;;
    html: {% if value == 'Yes' %}<p style="color: black; background-color: rgb(255,240,240); font-size:100%">Yes (aka MANY)</p>{% else %}<p style="color: black; background-color: rgb(180,255,180); font-size:100%">No (aka ONE)</p>{% endif %} ;;
  }


  dimension: total_rows_on_compare_to {
    label: "Not Null Rows on Compare To"
    type: number
    sql: ${TABLE}.total_rows_on_compare_to ;;
  }

  dimension: count_distinct_values_on_compare_to {
    type: number
    sql: ${TABLE}.count_distinct_values_on_compare_to ;;
  }

  dimension: percent_distinct_on_compare_to {
    type: number
    sql: ${TABLE}.percent_distinct_on_compare_to ;;
    value_format_name: percent_1
  }

  dimension: distinct_values_on_compare_only {
    type: number
    sql: ${TABLE}.distinct_values_on_compare_only ;;
  }

  dimension: distinct_values_on_both {
    type: number
    sql: ${TABLE}.distinct_values_on_both ;;
  }

  dimension: distinct_values_on_compare_to_only {
    type: number
    sql: ${TABLE}.distinct_values_on_compare_to_only ;;
  }

  dimension: join_lookml {
    type: string
    sql:'join: ' || ${compare_to_table_name} || '{' || 'sql_on: $' || '{' || ${compare_table_name} || '.' || ${compare_column_name} || '}=$' || '{' || ${compare_to_table_name} || '.' || ${compare_to_column_name} || '};' || ';' || ' relationship:' || ${relationsip} || ' type:' || ${join_type_no_right_outer} || '}';;
  }

  dimension: COMPARE_Row_Count {type:number}
  dimension: COMPARE_TO_Row_Count {type:number}

  dimension: percent_not_null_on_compare{
    type: number
    sql: ${total_rows_on_compare}*1.0/nullif(${COMPARE_Row_Count},0) ;;
    value_format_name: percent_1
    html:
    {% if value < 0.01 %}
    <p style="color: white; background-color: rgb(255,0,0); font-size:100%">{{ rendered_value }}</p>
    {% elsif value < 0.05 %}
    <p style="color: white; background-color: rgb(255,180,180); font-size:100%">{{ rendered_value }}</p>
    {% elsif value < 0.5 %}
    <p style="color: black; background-color: rgb(255,240,240); font-size:100%">{{ rendered_value }}</p>
    {% else %}
    <p>{{ rendered_value }}</p>
    {% endif %}
    ;;
  }

  dimension: percent_not_null_on_compare_to{
    type: number
    sql: ${total_rows_on_compare_to}*1.0/nullif(${COMPARE_TO_Row_Count},0) ;;
    value_format_name: percent_1
    html:
    {% if value < 0.01 %}
    <p style="color: white; background-color: rgb(255,0,0); font-size:100%">{{ rendered_value }}</p>
    {% elsif value < 0.05 %}
    <p style="color: white; background-color: rgb(255,180,180); font-size:100%">{{ rendered_value }}</p>
    {% elsif value < 0.5 %}
    <p style="color: white; background-color: rgb(255,240,240); font-size:100%">{{ rendered_value }}</p>
    {% else %}
    <p>{{ rendered_value }}</p>
    {% endif %}
    ;;
  }

  measure: distinct_values_on_both_measure {type:sum sql:${distinct_values_on_both};;}

  measure: distinct_values_on_compare_to_only_measure {type:sum sql:${distinct_values_on_compare_to_only};;}
  measure: distinct_values_on_compare_only_measure {type:sum sql:${distinct_values_on_compare_only};;}

  measure: distinct_values_on_compare {type:number sql:${distinct_values_on_both_measure}+${distinct_values_on_compare_only_measure};;}
  measure: distinct_values_on_compare_to {type:number sql:${distinct_values_on_both_measure}+${distinct_values_on_compare_to_only_measure};;}



  set: detail {
    fields: [
      sql_on,
      relationsip,
      join_type,
      message,
      compare_table_name,
      compare_column_name,
      compare_to_table_name,
      compare_to_column_name,
      many_to_many,
      one_to_many,
      many_to_one,
      field_unique_on_COMPARE,
      total_rows_on_compare,
      count_distinct_values_on_compare,
      percent_distinct_on_compare,
      field_unique_on_COMPARE_TO,
      total_rows_on_compare_to,
      count_distinct_values_on_compare_to,
      percent_distinct_on_compare_to,
      distinct_values_on_compare_only,
      distinct_values_on_both,
      distinct_values_on_compare_to_only
    ]
  }
}
