view: parameterized_sample_rows {
  derived_table: {
    sql:
    select {% parameter field_name_input_parameter %}::varchar as field,
    FIRST_VALUE({% parameter field_name_input_parameter %}::varchar IGNORE NULLS) OVER(order by {% parameter field_name_input_parameter %}::varchar rows between unbounded preceding and unbounded following) as minimum,
    FIRST_VALUE({% parameter field_name_input_parameter %}::varchar IGNORE NULLS) OVER(order by {% parameter field_name_input_parameter %}::varchar desc rows between unbounded preceding and unbounded following) as maximum,
    count(*) as row_count,
    count({% parameter field_name_input_parameter %}::varchar) as not_null_count
    from {% parameter table_name_input_parameter %}
    group by 1
    ;;
  }

  parameter: table_name_input_parameter {
    type: unquoted
  }

  parameter: field_name_input_parameter {
    type: unquoted
  }

  dimension: table_entry_value {
    type: string
    sql: '{% parameter table_name_input_parameter %}' ;;
  }

  dimension: field_entry_value {
    type: string
    sql: '{% parameter field_name_input_parameter %}' ;;
  }

  dimension: field {
    primary_key: yes
    label: "field:{% parameter field_name_input_parameter %}"
  }
  dimension: row_count {
    label: "{% assign x = _filters['table_name_input_parameter'] | append: ' - ' %}{% assign size = x | size %}{% if size < 4 %}{% else %}{{x}}{% endif%}{{_field._name | replace: '_',' ' | split: '.' | last }}"
  }
  dimension: not_null_count {
    label: "{% assign x = _filters['table_name_input_parameter'] | append: ' - ' %}{% assign size = x | size %}{% if size < 4 %}{% else %}{{x}}{% endif%}{{_field._name | replace: '_',' ' | split: '.' | last }}"
  }
  measure: total_rows {type:sum sql:${row_count};;
    label: "{% assign x = _filters['table_name_input_parameter'] | append:'.' | append: _filters['field_name_input_parameter'] | replace: '^',''  | append: ' - ' %}{% assign size = x | size %}{% if size < 5 %}{% else %}{{x}}{% endif%}{{_field._name | replace: '_',' ' | split: '.' | last }}"
  }
  measure: total_non_null_rows {type:sum sql:${not_null_count};;
    label: "{% assign x = _filters['table_name_input_parameter'] | append:'.' | append: _filters['field_name_input_parameter'] | replace: '^',''  | append: ' - ' %}{% assign size = x | size %}{% if size < 5 %}{% else %}{{x}}{% endif%}{{_field._name | replace: '_',' ' | split: '.' | last }}"
  }



  measure: count_distinct_values {
    label: "{% assign x = _filters['table_name_input_parameter'] | append:'.' | append: _filters['field_name_input_parameter'] | replace: '^',''  | append: ' - ' %}{% assign size = x | size %}{% if size < 5 %}{% else %}{{x}}{% endif%}{{_field._name | replace: '_',' ' | split: '.' | last }}"
    type:count_distinct sql:${field};;}

  dimension: min_value_dimension { sql: ${TABLE}.minimum;;}
  measure: min_value {
    label: "{% assign x = _filters['table_name_input_parameter'] | append:'.' | append: _filters['field_name_input_parameter'] | replace: '^',''  | append: ' - ' %}{% assign size = x | size %}{% if size < 5 %}{% else %}{{x}}{% endif%}{{_field._name | replace: '_',' ' | split: '.' | last }}"
    type: string
    sql: min(${min_value_dimension}::varchar) ;;
  }

  dimension: max_value_dimension { sql: ${TABLE}.maximum;;}
  measure: max_value {
    label: "{% assign x = _filters['table_name_input_parameter'] | append:'.' | append: _filters['field_name_input_parameter'] | replace: '^',''  | append: ' - ' %}{% assign size = x | size %}{% if size < 5 %}{% else %}{{x}}{% endif%}{{_field._name | replace: '_',' ' | split: '.' | last }}"
    type: string
    sql: max(${max_value_dimension}::varchar) ;;
  }

}
