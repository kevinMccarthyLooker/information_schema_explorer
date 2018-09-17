#Special Dependencies:
#Table_name and matching_table_name dimension needs to match connection name to enable direct link to an explore for that table.


view: information_schema__columns {
  derived_table: {
    sql:

    select * from

    (
    select
    table_schema:: varchar || '.' || table_name || '.' || column_name:: varchar  as table_schema__table_name__column_name,
    table_name || '.' || column_name:: varchar  as table_name__column_name,
    table_catalog:: varchar as table_catalog,
    table_schema:: varchar as table_schema,
    table_name:: varchar as table_name,
    column_name:: varchar as column_name,
    ordinal_position:: varchar as ordinal_position,
    column_default:: varchar as column_default,
    is_nullable:: varchar as is_nullable,
    data_type:: varchar as data_type,
    character_maximum_length::varchar as character_maximum_length,
    character_octet_length::varchar as character_octet_length,
    numeric_precision:: varchar as numeric_precision,
    numeric_precision_radix:: varchar as numeric_precision_radix,
    numeric_scale:: varchar as numeric_scale,
    datetime_precision:: varchar as datetime_precision,
    interval_type:: varchar as interval_type,
    interval_precision:: varchar as interval_precision,
    character_set_catalog:: varchar as character_set_catalog,
    character_set_schema:: varchar as character_set_schema,
    character_set_name:: varchar as character_set_name,
    collation_catalog:: varchar as collation_catalog,
    collation_schema:: varchar as collation_schema,
    collation_name:: varchar as collation_name,
    domain_catalog:: varchar as domain_catalog,
    domain_schema:: varchar as domain_schema,
    domain_name:: varchar as domain_name,
    udt_catalog:: varchar as udt_catalog,
    udt_schema:: varchar as udt_schema,
    udt_name:: varchar as udt_name,
    scope_catalog:: varchar as scope_catalog,
    scope_schema:: varchar as scope_schema,
    scope_name:: varchar as scope_name ,
    maximum_cardinality:: varchar as maximum_cardinality ,
    is_self_referencing:: varchar as is_self_referencing,
    dtd_identifier:: varchar as dtd_identifier
    /*
    ,

    --Cross Joined Field
    case when table_name=matching_table_schema and column_name=matching_column_name then 'self' else matching_table_name__column_name end as matching_table_name__column_name,
    matching_table_catalog,
    matching_table_schema,
    matching_table_name,
    matching_column_name,
    matching_data_type,

    --match criteria definitions
    case when data_type=matching_data_type then

      case
        when table_name || '.' || column_name=matching_columns.matching_table_name__column_name then 'self'
        --field's table name matches to foreign key on match table
        when (case when right(table_name,1)='s' then left(table_name,len(table_name)-1) else table_name end) = replace(matching_column_name,'_id','')
              and column_name='id'
              then 'table_id_match'
        when (case when right(table_name,1)='s' then left(table_name,len(table_name)-1) else table_name end like '%'|| replace(matching_column_name,'_id','')||'%')
              and column_name='id'
              then 'table_id_match_to_substring'
        when (case when right(matching_table_name,1)='s' then left(matching_table_name,len(matching_table_name)-1) else matching_table_name end) = replace(column_name,'_id','')
              and matching_column_name='id'
              then 'possible_foreign_key'
        when column_name = matching_column_name
          --exclusions for common field names that don't demonstrate a meaningful relationship
          and column_name not in ('id','created_at','type','name') then 'field_name_in_common'
      else 'none'
      end
    else 'none'
    end as match_type
    */

    from information_schema.columns

    /*
    cross join
    (select
    table_name || '.' || column_name:: varchar  as matching_table_name__column_name,
    table_catalog:: varchar as matching_table_catalog,
    table_schema:: varchar as matching_table_schema,
    table_name:: varchar as matching_table_name,
    column_name:: varchar as matching_column_name,
    data_type:: varchar as matching_data_type
    from
    information_schema.columns as matching_columns
    where matching_columns.table_schema in ('looker_scratch','public')
    group by 1,2,3,4,5,6
    ) matching_columns
    */
    where
    columns.table_schema != 'pg_catalog' and columns.table_schema != 'information_schema'

    )


    where
    /*
    match_type = 'self'
    or
    ((match_type = 'table_id_match' or match_type='table_id_match_sub') and column_name='id')
    or
    match_type='possible_foreign_key'
    or
    match_type='field_name_in_common'

    and
    */
    {% condition information_schema__columns.table_schema %}table_schema{% endcondition %}
    and
    {% condition information_schema__columns.table_name %}table_name{% endcondition %}
    and
    {% condition information_schema__columns.column_name %}column_name{% endcondition %}

           ;;

    }

#   dimension: primary_key__field_pair {primary_key:yes sql: ${table_name}||${column_name}||${matching_table_name}||${matching_column_name} ;;}
#
#   dimension: primary_key__field_pair_as_join_criteria{sql: ${table_name}||'.'||${column_name}||'='||${matching_table_name}||'.'||${matching_column_name} ;;}
#
#
#   dimension: likely_key_type {
#     case: {
#       when: {sql:${column_name}='id';; label:"primary_key"}
#       when: {sql:${column_name} like '%_id';; label:"foreign_key"}
#       else: ""
#     }
#   }
#
#
#   dimension: match_type {}
#
#   dimension: matching_table_name__column_name {}
#   dimension: matching_table_catalog {}
#   dimension: matching_table_schema {}
#   dimension: matching_table_name {
#     link: {
#       label: "Table Dashboard: {{value}}"
#       url: "https://vydia.looker.com/dashboards/25?Table={{value}}"
#     }
#     #sends to an explore for the table.  the text between t__ and __{{table_schema._value}} needs to match the connection name
#   link: {
#     label: "Explore Table: {{value}}"
#     url: "https://vydia.looker.com/explore/t__redshift_production_as_looker__{{matching_table_schema._value}}__{{value}}/table?fields={{value}}.count"
#     }
#     link: {
#       label: "check join definition"
#       url: "/explore/z_information_schema_columns/profiling__compare_two_fields?fields=profiling__compare_two_fields.join_lookml,profiling__compare_two_fields.compare_table_name,profiling__compare_two_fields.compare_column_name,profiling__compare_two_fields.compare_to_table_name,profiling__compare_two_fields.compare_to_column_name,profiling__compare_two_fields.total_rows_on_compare,profiling__compare_two_fields.count_distinct_values_on_compare,profiling__compare_two_fields.percent_distinct_on_compare,profiling__compare_two_fields.field_unique_on_COMPARE,profiling__compare_two_fields.total_rows_on_compare_to,profiling__compare_two_fields.count_distinct_values_on_compare_to,profiling__compare_two_fields.percent_distinct_on_compare_to,profiling__compare_two_fields.field_unique_on_COMPARE_TO,profiling__compare_two_fields.distinct_values_on_compare_only,profiling__compare_two_fields.distinct_values_on_both,profiling__compare_two_fields.distinct_values_on_compare_to_only,profiling__compare_two_fields.join_type,profiling__compare_two_fields.many_to_one,profiling__compare_two_fields.many_to_many,profiling__compare_two_fields.one_to_many,profiling__compare_two_fields.relationsip,profiling__compare_two_fields.sql_on,profiling__compare_two_fields.message&f[profiling__compare_two_fields.compare_table_name_input_parameter]={{ table_name._value | encode_uri  | replace: '_','^_' }}&f[profiling__compare_two_fields.compare_field_name_input_parameter]={{ column_name._value | encode_uri | replace: '_','^_' }}&f[profiling__compare_two_fields.compare_to_table_name_input_parameter]={{ matching_table_name._value | encode_uri  | replace: '_','^_' }}&f[profiling__compare_two_fields.compare_to_field_name_input_parameter]={{ matching_column_name._value | encode_uri  | replace: '_','^_' }}&sorts=profiling__compare_two_fields.compare_table_name&vis=%7B%22show_view_names%22%3Afalse%2C%22type%22%3A%22looker_single_record%22%2C%22show_row_numbers%22%3Afalse%2C%22truncate_column_names%22%3Afalse%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22table_theme%22%3A%22editable%22%2C%22limit_displayed_rows%22%3Afalse%2C%22enable_conditional_formatting%22%3Afalse%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22series_types%22%3A%7B%7D%7D"
#
#     }
#   }
#   dimension: matching_column_name {
#     link: {
#       label:"Column Dashboard: {{matching_table_name._value}}.{{value}}"
#       url: "https://vydia.looker.com/dashboards/27?Table={{ matching_table_name._value | url_encode | replace: '_','%5E_'}}&Column={{ value | url_encode | replace: '_','%5E_'}}"
#     }
#     link: {
#       label:"Table Explore: Column Breakdown: {{matching_table_name._value}}.{{value}}"
#       url: "https://vydia.looker.com/explore/t__redshift_production_as_looker__{{matching_table_schema._value}}__{{matching_table_name._value}}/table?fields={{matching_table_name._value}}.count,{{matching_table_name._value}}.{{value}}"
#     }
#     link: {
#       label:"Test this Join: {{primary_key__field_pair_as_join_criteria._value}}"
#       url: "https://vydia.looker.com/explore/z_information_schema_columns/profiling__compare_two_fields?fields=profiling__compare_two_fields.sql_on, profiling__compare_two_fields.count_distinct_values_on_compare_to,profiling__compare_two_fields.distinct_values_on_both, profiling__compare_two_fields.distinct_values_on_compare_only,profiling__compare_two_fields.distinct_values_on_compare_to_only, profiling__compare_two_fields.count_distinct_values_on_compare,profiling__compare_two_fields.join_type, profiling__compare_two_fields.percent_distinct_on_compare,profiling__compare_two_fields.percent_distinct_on_compare_to, profiling__compare_two_fields.relationsip,profiling__compare_two_fields.count, profiling__compare_two_fields.total_rows_on_compare,profiling__compare_two_fields.total_rows_on_compare_to&f[profiling__compare_two_fields.compare_field_name_input_parameter]={{column_name._value}}&f[profiling__compare_two_fields.compare_table_name_input_parameter]={{table_name._value}}&f[profiling__compare_two_fields.compare_to_field_name_input_parameter]={{matching_column_name._value | url_encode | replace: '_','%5E_'}}&f[profiling__compare_two_fields.compare_to_table_name_input_parameter]={{matching_table_name._value | url_encode | replace: '_','%5E_'}}"
#     }
#
# #     https://vydia.looker.com/explore/z_information_schema_columns/profiling__compare_two_fields?toggle=fil&qid=l5b5SwxMWWKpNXNrwDLVxv
#   }
#
#   dimension: matching_data_type {}

#   dimension: table_catalog { group_label:" Schema Info" hidden:yes }#according to docs this is always the current database https://www.postgresql.org/docs/9.5/static/infoschema-tables.html
#   dimension: table_catalog_dot_table_schema {group_label:" Schema Info" label:"Catalog.Schema" sql:${table_catalog}||'.'||${table_schema};;}

    dimension: table_schema__table_name__column_name {label:"Schema.Table.Column" group_label:" Schema Info" }
    dimension: table_name__column_name { label:" Table__Column"  }
    dimension: table_schema { group_label:" Schema Info" }
    dimension: table_name {
      link: {
        label: "Table Dashboard: {{value}}"
        url: "https://vydia.looker.com/dashboards/25?Table={{ value | url_encode | replace: '_','%5E_'}}"
      }
      link: {
        #sends to an explore for the table.  the text between t__ and __{{table_schema._value}} needs to match the connection name
        label: "Explore Database Table: {% assign schema = table_schema._value %}{% if schema == 'looker_scratch' %}(DOESN'T CURRENTLY WORK FOR LOOKER_SCRATCH TABLES){% else %}{{value}}{% endif %}"
#       url: "https://vydia.looker.com/dashboards/25?Table={{value}}"
        url: "https://vydia.looker.com/explore/t__redshift_production_as_looker__{{table_schema._value}}__{{value}}/table?fields={{value}}.count"
      }

    }
    dimension: column_name {
      link: {
        label: "Column Dashboard: {{table_name._value}}.{{value}}"
        url: "https://vydia.looker.com/dashboards/27?Table={{ table_name._value | url_encode | replace: '_','%5E_'}}&Column={{ value | url_encode | replace: '_','%5E_'}}"
      }
      link: {
        label:"Table Explore: Column Breakdown: {{table_name._value}}.{{value}}"
        #url: "https://vydia.looker.com/explore/t__redshift_production_as_looker__{{table_schema._value}}__{{table_name._value}}/table?fields={{table_name._value}}.count,{{table_name._value}}.{{value}}"
#       url: "../explore/t__redshift_production_as_looker__{{table_schema._value}}__{{table_name._value}}/table?fields={{table_name._value}}.count,{{table_name._value}}.{{value}}"
        #does not work when drilling from another explore.
        #consider using HTML references instead.
        url: "../explore/t__{{variables.connection_name._sql | remove: \"'\" }}__{{table_schema._value}}__{{table_name._value}}/table?fields={{table_name._value}}.count,{{table_name._value}}.{{value}}{% if data_type._value == 'timestamp without time zone' %}_date{% endif %}"
      }
    }


    dimension: ordinal_position { group_label:" Other Info" }

    dimension: column_default { group_label:" Other Info" }

    dimension: is_nullable { group_label:" Other Info" }

    dimension: data_type {}

    dimension: data_type_date_extension {
      type: string
      #can never be used
      sql:
          {% assign d=data_type._value %}
          {% if d == 'timestamp without time zone' %}'_date{{d}}'{% else %}'nope-{{d}}-'{% endif %} ;;
    }

    dimension: character_maximum_length { group_label:" Other Info" }

    dimension: character_octet_length { group_label:" Other Info" }

    dimension: numeric_precision { group_label:" Other Info" }

    dimension: numeric_precision_radix { group_label:" Other Info" }

    dimension: numeric_scale { group_label:" Other Info" }

    dimension: datetime_precision { group_label:" Other Info" }

    dimension: interval_type  { group_label:" Other Info" }

    dimension: interval_precision  { group_label:" Other Info" }

    dimension: character_set_catalog  { group_label:" Other Info" }

    dimension: character_set_schema { group_label:" Other Info" }

    dimension: character_set_name  { group_label:" Other Info" }

    dimension: collation_catalog { group_label:" Other Info" }

    dimension: collation_schema  { group_label:" Other Info" }

    dimension: collation_name  { group_label:" Other Info" }

    dimension: domain_catalog { group_label:" Other Info" }

    dimension: domain_schema { group_label:" Other Info" }

    dimension: domain_name { group_label:" Other Info" }

    dimension: udt_catalog  { group_label:" Other Info" }

    dimension: udt_schema  { group_label:" Other Info" }

    dimension: udt_name { group_label:" Other Info" }

    dimension: scope_catalog  { group_label:" Other Info" }

    dimension: scope_schema { group_label:" Other Info" }

    dimension: scope_name { group_label:" Other Info" }

    dimension: maximum_cardinality  { group_label:" Other Info" }

    dimension: is_self_referencing { group_label:" Other Info" }

    dimension: dtd_identifier { group_label:" Other Info" }

    measure: count {type:count}

    measure: count_distinct_columns {
      type: count_distinct
      sql: ${table_name__column_name}  ;;
    }

    measure: count_distinct_tables {
      type: count_distinct
      sql: ${table_name} ;;
    }


#   dimension: join_definition_check_link {
#     type: string
#     sql: 'link';;
#     link: {
#       label: "test join check link"
# #       url: "/explore/z_information_schema_columns/profiling__compare_two_fields?fields=profiling__compare_two_fields.join_lookml,profiling__compare_two_fields.compare_table_name,profiling__compare_two_fields.compare_column_name,profiling__compare_two_fields.compare_to_table_name,profiling__compare_two_fields.compare_to_column_name,profiling__compare_two_fields.total_rows_on_compare,profiling__compare_two_fields.count_distinct_values_on_compare,profiling__compare_two_fields.percent_distinct_on_compare,profiling__compare_two_fields.field_unique_on_COMPARE,profiling__compare_two_fields.total_rows_on_compare_to,profiling__compare_two_fields.count_distinct_values_on_compare_to,profiling__compare_two_fields.percent_distinct_on_compare_to,profiling__compare_two_fields.field_unique_on_COMPARE_TO,profiling__compare_two_fields.distinct_values_on_compare_only,profiling__compare_two_fields.distinct_values_on_both,profiling__compare_two_fields.distinct_values_on_compare_to_only,profiling__compare_two_fields.join_type,profiling__compare_two_fields.many_to_one,profiling__compare_two_fields.many_to_many,profiling__compare_two_fields.one_to_many,profiling__compare_two_fields.relationsip,profiling__compare_two_fields.sql_on,profiling__compare_two_fields.message
# #       &f[profiling__compare_two_fields.compare_table_name_input_parameter]=artists
# #       &f[profiling__compare_two_fields.compare_field_name_input_parameter]=id
# #       &f[profiling__compare_two_fields.compare_to_table_name_input_parameter]=medias
# #       &f[profiling__compare_two_fields.compare_to_field_name_input_parameter]=artist%5E_id
# #       &sorts=profiling__compare_two_fields.compare_table_name&vis=%7B%22show_view_names%22%3Afalse%2C%22type%22%3A%22looker_single_record%22%2C%22show_row_numbers%22%3Afalse%2C%22truncate_column_names%22%3Afalse%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22table_theme%22%3A%22editable%22%2C%22limit_displayed_rows%22%3Afalse%2C%22enable_conditional_formatting%22%3Afalse%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22series_types%22%3A%7B%7D%7D"
#       url: "/explore/z_information_schema_columns/profiling__compare_two_fields?fields=profiling__compare_two_fields.join_lookml,profiling__compare_two_fields.compare_table_name,profiling__compare_two_fields.compare_column_name,profiling__compare_two_fields.compare_to_table_name,profiling__compare_two_fields.compare_to_column_name,profiling__compare_two_fields.total_rows_on_compare,profiling__compare_two_fields.count_distinct_values_on_compare,profiling__compare_two_fields.percent_distinct_on_compare,profiling__compare_two_fields.field_unique_on_COMPARE,profiling__compare_two_fields.total_rows_on_compare_to,profiling__compare_two_fields.count_distinct_values_on_compare_to,profiling__compare_two_fields.percent_distinct_on_compare_to,profiling__compare_two_fields.field_unique_on_COMPARE_TO,profiling__compare_two_fields.distinct_values_on_compare_only,profiling__compare_two_fields.distinct_values_on_both,profiling__compare_two_fields.distinct_values_on_compare_to_only,profiling__compare_two_fields.join_type,profiling__compare_two_fields.many_to_one,profiling__compare_two_fields.many_to_many,profiling__compare_two_fields.one_to_many,profiling__compare_two_fields.relationsip,profiling__compare_two_fields.sql_on,profiling__compare_two_fields.message&f[profiling__compare_two_fields.compare_table_name_input_parameter]={{ table_name._value | encode_uri  | replace: '_','^_' }}&f[profiling__compare_two_fields.compare_field_name_input_parameter]={{ column_name._value | encode_uri | replace: '_','^_' }}&f[profiling__compare_two_fields.compare_to_table_name_input_parameter]={{ matching_table_name._value | encode_uri  | replace: '_','^_' }}&f[profiling__compare_two_fields.compare_to_field_name_input_parameter]={{ matching_column_name._value | encode_uri  | replace: '_','^_' }}&sorts=profiling__compare_two_fields.compare_table_name&vis=%7B%22show_view_names%22%3Afalse%2C%22type%22%3A%22looker_single_record%22%2C%22show_row_numbers%22%3Afalse%2C%22truncate_column_names%22%3Afalse%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22table_theme%22%3A%22editable%22%2C%22limit_displayed_rows%22%3Afalse%2C%22enable_conditional_formatting%22%3Afalse%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22series_types%22%3A%7B%7D%7D"
#
#     }
#   }

  }
