view: columns_basic {
  derived_table: {
    sql:
    select
    table_name || '__' || column_name:: varchar  as table_name__column_name,
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

    from information_schema.columns

    where table_schema in ('looker_scratch','public')


           ;;


    }


    dimension: table_name__column_name {primary_key: yes label:" Table__Column"  }
    dimension: table_name {  }
    dimension: column_name {  }

    dimension: table_catalog { group_label:" Schema Info" }
    dimension: table_schema { group_label:" Schema Info" }

    dimension: ordinal_position { group_label:" Other Info" }

    dimension: column_default { group_label:" Other Info" }

    dimension: is_nullable { group_label:" Other Info" }

    dimension: data_type {}

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

  }
