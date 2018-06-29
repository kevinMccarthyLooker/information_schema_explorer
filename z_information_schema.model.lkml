#files to remove from sandbox:
#z_information_schema_columns

connection: "redshift_production_as_looker"
include: "information_schema__columns.view.lkml"
include: "matching_columns.view.lkml"
include: "possible_keys.view.lkml"
include: "tables.*"
include: "columns_basic.*"
include: "columns.*"
include: "parameterized_table_profile.*"
include: "parameterized_sample_rows.*"
include: "table_column_stats.view"
include: "information_schema__columns_matching.view"


#current explores:
include: "pg_table_def.*"

#can be used to declare global variables of sorts
view: variables {dimension: connection_name {sql:'redshift_production_as_looker';;}}

explore: information_schema__columns {
  join: information_schema__columns_matching {
    sql_on:
        ${information_schema__columns.table_schema} =${information_schema__columns_matching.table_schema}
    and ${information_schema__columns.table_name}   =${information_schema__columns_matching.table_name}
    and ${information_schema__columns.column_name}  =${information_schema__columns_matching.column_name}
    ;;
    relationship: one_to_many
  }
  fields: [ALL_FIELDS*,-pg_table_def.hidden_fields*,-table_column_stats.hidden_fields*]
  join: pg_table_def {
    sql_on:
      ${information_schema__columns.table_name}=${pg_table_def.tablename}
      and ${information_schema__columns.column_name}=${pg_table_def.column}
    ;;
    relationship: many_to_one
  }
  join: pg_table_def_hidden_fields {fields: [hidden_fields*]sql:;;relationship: one_to_one required_joins:[pg_table_def]}
join: table_column_stats {
#     fields: [table_column_stats.approximate_values_count]
sql_on:
        ${information_schema__columns.table_schema}=${table_column_stats.schemaname}
    and ${information_schema__columns.table_name}=${table_column_stats.tablename}
    and ${information_schema__columns.column_name}=${table_column_stats.attname}
    ;;
relationship: many_to_one
}
#This sql-less join creates a seperate header for fields you can quickly toggle as visible or invisible.
join: table_column_stats_hidden_fields{fields: [hidden_fields*]sql:;;relationship: one_to_one}
#since different column's stats may give different row counts for the table, this rollup is used for row table's row count, for use when totalling across multiple tables.
join: table_column_stats__table_rows {
#     sql_on:
#         ${information_schema__columns.table_schema}=${table_column_stats__table_rows.schemaname}
#     and ${information_schema__columns.table_name}=${table_column_stats__table_rows.tablename} ;;
sql_on:
        ${information_schema__columns.table_schema}=${table_column_stats__table_rows.table_schema}
    and ${information_schema__columns.table_name}=${table_column_stats__table_rows.table_name} ;;
relationship: many_to_one
}


#can be used to declare global variables of sorts.  blank sql clause means that no join is used at all.
join: variables {sql:;;relationship:one_to_one}

}

explore: parameterized_table_profile {}

explore: parameterized_sample_rows {}

include: "profiling*"
explore: profiling__compare_two_fields {}

explore: tables {}


# include: "medias*"
# include: "artists*"
# explore: testing_join_suggestion_output {
#   view_name: medias
#   join: artists{sql_on: ${medias.artist_id}=${artists.id};; relationship:many_to_one type:full_outer}
# }

explore: columns_basic {}
# include: "broadcasts*"
# explore: broadcasts {
#   join: bundles{sql_on: ${broadcasts.bundle_id}=${bundles.id};; relationship:many_to_one type:full_outer}
#
# }


# ####old test views/explores?
# explore: possible_keys {
#   sql_always_where:  ${possible_keys.column_name}='id';;
#   view_label: "1) Table Column"
#   join: matching_columns {
#     view_label: "2) Compare Column"
#     type: cross
#     relationship: one_to_many
#   }
# }
# explore: tables {}
# explore: columns_basic {}
# #####

explore: columns {}
