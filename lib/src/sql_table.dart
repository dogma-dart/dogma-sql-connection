// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// Contains the [SqlTable] class.
library dogma_sql_connection.src.sql_table;

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'sql_column.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

class SqlTable {
  final List<SqlColumn> columns;
  final String name;

  SqlTable(this.name, this.columns);
}
