create or replace PROCEDURE  cmx_prc_lista_chamadas(pc_ano         cmx_tmp_lista_chamadas.ano        %TYPE,
                                                      pc_mes         cmx_tmp_lista_chamadas.mes        %TYPE,
                                                      pc_teacher_id  cmx_tmp_lista_chamadas.teacher_id %TYPE)
  IS
   --
   l_reg_t CMX_TMP_LISTA_CHAMADAS%ROWTYPE;
   --
   vc_mes               VARCHAR2(2);
   vc_ano               VARCHAR2(4);
   vd_dataini           DATE;
   vd_datafim           DATE;
   vd_data              DATE;
   l_cont               NUMBER := 0;
   vn_cmx_time_segunda  VARCHAR2(1);
   vn_cmx_time_terca    VARCHAR2(1);
   vn_cmx_time_quarta   VARCHAR2(1);
   vn_cmx_time_quinta   VARCHAR2(1);
   vn_cmx_time_sexta    VARCHAR2(1);
   --
   TYPE table_dia IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   g_tb_table_dia table_dia;
   --
    CURSOR c_tabela_completa
    IS 
       select cti.time || ' ' || decode(cti.FLAG_MONDAY   ,'Y', '2a ') || ' ' ||
                                 decode(cti.FLAG_TUESDAY  ,'Y', '3a ') || ' ' ||   
                                 decode(cti.FLAG_WEDNESDAY,'Y', '4a ') || ' ' ||  
                                 decode(cti.FLAG_THURSDAY ,'Y', '5a ') || ' ' ||  
                                 decode(cti.FLAG_FRIDAY ,'Y', '6a ') as D_Horario
        ,cti.time_id AS R_Horario
        ,cts.sala 
        ,cls.name as D_turma 
        ,cls.class_id R_turma
        ,cte.name as D_Professor
        ,cte.TEACHER_ID  as R_professor
        ,cmt.name || ' ' ||  decode(cti.FLAG_MONDAY   ,'Y', '2a ') || ' ' ||
                             decode(cti.FLAG_TUESDAY  ,'Y', '3a ') || ' ' ||   
                             decode(cti.FLAG_WEDNESDAY,'Y', '4a ') || ' ' ||  
                             decode(cti.FLAG_THURSDAY ,'Y', '5a ') || ' ' ||  
                             decode(cti.FLAG_FRIDAY ,'Y', '6a ')   || ' ' || 
                             decode(cmt.FLAG_STATUS
                                                ,'A', 'ATIVO'
                                                ,'E', 'EXPERIMENTAL'
                                                ,'I', 'INATIVO'
                                                ,'W', 'ESPERA'
                                                ,'F', 'CONGELADO') || '  ' ||'('||cmt.DT_STATUS||')' || ' Data Nascimento: ' || DT_BIRTH AS D_aluno,
            cmt.STUDANT_ID as R_aluno
    from CMX_TEACHER cte
       ,cmx_team    ct
       ,cmx_time    cti
       ,cmx_sala    cts
       ,cmx_class   cls
       ,cmx_studant cmt
    where cte.teacher_id = ct.teacher_id
    and   cti.time_id    = ct.time_id
    AND   ct.class_id    = cls.class_id
    and   cti.sala_id    = cts.sala_id
    and   cmt.TEAM_ID    = ct.TEAM_ID
    and   cte.teacher_id = pc_teacher_id;
    --
  BEGIN
    --
    DELETE FROM CMX_TMP_LISTA_CHAMADAS;
    --
    COMMIT;
    --
    vc_mes     := pc_mes;
    vc_ano     := pc_ano;
    vd_dataini := TRUNC( to_date('10' || '/' || vc_mes || '/' || vc_ano, 'DD/MM/YYYY'),'MM');
    vd_datafim := LAST_DAY(to_date('10' || '/' || vc_mes || '/' || vc_ano, 'DD/MM/YYYY'));   
    --
    vd_data := vd_dataini-1;
    --
   FOR l_reg IN c_tabela_completa LOOP
      --
      g_tb_table_dia.DELETE;
      --
      l_reg_t.ANO         := pc_ano;
      l_reg_t.MES         := pc_mes;
      l_reg_t.TIME_ID     := l_reg.R_Horario;   
      l_reg_t.CLASS_ID    := l_reg.R_turma;
      l_reg_t.TEACHER_ID  := l_reg.R_professor;
      l_reg_t.STUDANT_ID  := l_reg.R_aluno;
      --
      -- LOGICA DO VETOR 
     select decode(flag_monday,'Y','2', null ) as segunda
          , decode(flag_tuesday,'Y','3', null ) as terca
          , decode(flag_wednesday,'Y','4', null ) as quarta
          , decode(flag_thursday,'Y','5', null ) as quinta
          , decode(flag_friday,'Y','6', null ) as sexta
      into vn_cmx_time_segunda
          ,vn_cmx_time_terca  
          ,vn_cmx_time_quarta 
          ,vn_cmx_time_quinta 
          ,vn_cmx_time_sexta  
     from CMX_STUDANT
      where STUDANT_ID = l_reg.R_aluno;
      -- 
      LOOP
        --
        vd_data := vd_data + 1;
        --
        EXIT WHEN (vd_data > vd_datafim);
        --
        l_cont  := l_cont + 1;
        --limpar vetor
       -- g_tb_table_dia.DELETE; 
          g_tb_table_dia(l_cont) := NULL;
        --
      END LOOP;
  --
  vd_data := vd_dataini - 1; 
  --
  l_cont := 0;
  --
  LOOP
    --
    vd_data := vd_data + 1;
    --
    EXIT WHEN (vd_data > vd_datafim);
    --
    IF TO_CHAR(vd_data, 'D') = '2' AND vn_cmx_time_segunda = '2' THEN
      --
      l_cont  := l_cont + 1;
      g_tb_table_dia(l_cont) :=  TO_CHAR(vd_data,'DD');
      --
    END IF;
    --
    IF TO_CHAR(vd_data, 'D') = '3' AND vn_cmx_time_terca = '3' THEN
      --
      l_cont  := l_cont + 1;
      g_tb_table_dia(l_cont) :=  TO_CHAR(vd_data,'DD');
      --
    END IF;
    --
    IF TO_CHAR(vd_data, 'D') = '4' AND vn_cmx_time_quarta = '4' THEN
      --
      l_cont  := l_cont + 1;
      g_tb_table_dia(l_cont) :=  TO_CHAR(vd_data,'DD');
      --
    END IF;
    --
    IF TO_CHAR(vd_data, 'D') = '5' AND vn_cmx_time_quinta = '5' THEN
      --
      l_cont  := l_cont + 1;
      g_tb_table_dia(l_cont) :=  TO_CHAR(vd_data,'DD');
      --
    END IF;
    --
    IF TO_CHAR(vd_data, 'D') = '6' AND vn_cmx_time_sexta = '6' THEN
      --
      l_cont  := l_cont + 1;
      g_tb_table_dia(l_cont) :=  TO_CHAR(vd_data,'DD');
      --
    END IF;
    --
   END LOOP;
    --
    l_reg_t.DIA1        :=   CASE WHEN g_tb_table_dia.EXISTS(1) THEN g_tb_table_dia(1) ELSE NULL END;--g_tb_table_dia(1);  
    l_reg_t.DIA2        :=   CASE WHEN g_tb_table_dia.EXISTS(2) THEN g_tb_table_dia(2) ELSE NULL END;-- g_tb_table_dia(2);
    l_reg_t.DIA3        :=   CASE WHEN g_tb_table_dia.EXISTS(3) THEN g_tb_table_dia(3) ELSE NULL END;--g_tb_table_dia(3);
    l_reg_t.DIA4        :=   CASE WHEN g_tb_table_dia.EXISTS(4) THEN g_tb_table_dia(4) ELSE NULL END;--g_tb_table_dia(4); 
    l_reg_t.DIA5        :=   CASE WHEN g_tb_table_dia.EXISTS(5) THEN g_tb_table_dia(5) ELSE NULL END;--g_tb_table_dia(5);
    l_reg_t.DIA6        :=   CASE WHEN g_tb_table_dia.EXISTS(6) THEN g_tb_table_dia(6) ELSE NULL END;--g_tb_table_dia(6);
    l_reg_t.DIA7        :=   CASE WHEN g_tb_table_dia.EXISTS(7) THEN g_tb_table_dia(7) ELSE NULL END;--g_tb_table_dia(7);
    l_reg_t.DIA8        :=   CASE WHEN g_tb_table_dia.EXISTS(8) THEN g_tb_table_dia(8) ELSE NULL END;--g_tb_table_dia(8);
    l_reg_t.DIA9        :=   CASE WHEN g_tb_table_dia.EXISTS(9) THEN g_tb_table_dia(9) ELSE NULL END;--g_tb_table_dia(9);
    l_reg_t.DIA10       :=   CASE WHEN g_tb_table_dia.EXISTS(10) THEN g_tb_table_dia(10) ELSE NULL END;--g_tb_table_dia(10);
    l_reg_t.DIA11       :=   CASE WHEN g_tb_table_dia.EXISTS(11) THEN g_tb_table_dia(11) ELSE NULL END;--g_tb_table_dia(11);
    l_reg_t.DIA12       :=   CASE WHEN g_tb_table_dia.EXISTS(12) THEN g_tb_table_dia(12) ELSE NULL END;--g_tb_table_dia(12);
    l_reg_t.DIA13       :=   CASE WHEN g_tb_table_dia.EXISTS(13) THEN g_tb_table_dia(13) ELSE NULL END;--g_tb_table_dia(13);
    l_reg_t.DIA14       :=   CASE WHEN g_tb_table_dia.EXISTS(14) THEN g_tb_table_dia(14) ELSE NULL END;--g_tb_table_dia(14);
    l_reg_t.DIA15       :=   CASE WHEN g_tb_table_dia.EXISTS(15) THEN g_tb_table_dia(15) ELSE NULL END;--g_tb_table_dia(15);
    l_reg_t.DIA16       :=   CASE WHEN g_tb_table_dia.EXISTS(16) THEN g_tb_table_dia(16) ELSE NULL END;-- g_tb_table_dia(16);
    l_reg_t.DIA17       :=   CASE WHEN g_tb_table_dia.EXISTS(17) THEN g_tb_table_dia(17) ELSE NULL END;-- g_tb_table_dia(17);
    l_reg_t.DIA18       :=   CASE WHEN g_tb_table_dia.EXISTS(18) THEN g_tb_table_dia(18) ELSE NULL END;-- g_tb_table_dia(18);
    l_reg_t.DIA19       :=   CASE WHEN g_tb_table_dia.EXISTS(19) THEN g_tb_table_dia(19) ELSE NULL END;-- g_tb_table_dia(19);
   
      --
      -- INSERT DO VETOR
      --
      INSERT INTO cmx_tmp_lista_chamadas VALUES l_reg_t;
      --
 END LOOP;  
    --
    COMMIT;
    --
  END cmx_prc_lista_chamadas;
/