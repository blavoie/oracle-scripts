/*
Copyright (c) 2007 Blue Gecko, Inc
License:

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

-- template for explaining sql and formatting the output nicely

DELETE FROM  plan_table
  WHERE statement_id = 'my_statement';
COMMIT;
SET HEADING OFF
SET LINESIZE 120
SET ECHO ON
EXPLAIN PLAN
   SET STATEMENT_ID = 'my_statement'
FOR
SELECT /*+ rule */
          cic.rowid,
          csi.item_fifo_cost correct_cost
        FROM
          customer_shipment_items csi,
          consumed_inventory_costs cic
        WHERE
          cic.inventory_cost_id         >= 10            AND
          cic.inventory_cost_id         =  csi.inventory_cost_id         AND
          cic.cost                      =  trunc(cic.cost)               AND
          cic.cost                      != csi.item_fifo_cost            AND
          cic.cost_reference_id_source  =  'CUSTOMER_RETURN_ITEM'        AND
          csi.customer_shipment_item_id >= 100
/
SET ECHO OFF
SELECT LPAD( '  ', 2 * ( LEVEL - 1 ) ) || 
       DECODE( id, 0, operation || '  (Cost = ' || position || ')',
       LEVEL - 1 || '.' || NVL( position, 0 ) || 
       '  ' || operation || 
       '  ' || options ||
       '  ' || object_name ||
       '  ' || object_type ||
       '  ' || object_node ) "Query Plan"
  FROM plan_table
  START WITH id = 0 AND statement_id = 'my_statement'
  CONNECT BY PRIOR id = parent_id AND statement_id = 'my_statement';
SET HEADING ON









