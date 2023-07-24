-- Script : IDIT_EstiGLExport.sql
-- Count all transactions electable transactions for next GL Export

SELECT DISTINCT count(ac_entry.transaction_id)
FROM ac_gl_interface
JOIN ac_entry ON ac_gl_interface.entry_id=ac_entry.id
JOIN AC_GL_INTERFACE_TCS ON AC_GL_INTERFACE_TCS.ID = ac_gl_interface.ID
LEFT JOIN P_POL_HEADER PH ON ac_entry.POLICY_HEADER_ID = PH.ID
WHERE ac_gl_interface.status = 1
  AND ac_gl_interface.transfer_nr IS NULL
  AND (PH.PRODUCT_ID IS NULL
       OR PH.PRODUCT_ID != 1000009)--DO NOT TAKE Company Card policy
  AND ac_gl_interface.LINE_ID IS NULL
  AND (TRANSACTION_TYPE IN
         (SELECT ID
          FROM T_TRANSACTION_TYPE_TCS
          WHERE GL_AGGREGATION_FLAG = 0
            OR GL_AGGREGATION_FLAG IS NULL
            OR (GL_AGGREGATION_FLAG = 1
                AND AC_GL_INTERFACE_TCS.SPECIAL_PROCESS_ID IN(1000001,
                                                              1000002))))