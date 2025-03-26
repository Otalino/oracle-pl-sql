create or replace PROCEDURE CMX_PROC_FATURA(pc_ano      IN varchar2,
                             pc_mes      IN varchar2,
                             pc_contador OUT number)
  IS
  CURSOR c_dados_alunos_A 
    IS 
    SELECT 
        cmt.flag_status,
        cmt.rg_cpf,
        cmt.studant_id,
        cmt.tip_plano,
        cmt.plano,
        cmc.class_id,
        cmc.name AS turma,
        cmi.cpf AS cpf_responsavel,
        cmi.name as nome_responsavel,
        cmi.phone,
        SUM(
            DECODE(cmt.flag_monday   , 'Y', 1, 0) +
            DECODE(cmt.flag_tuesday  , 'Y', 1, 0) +
            DECODE(cmt.flag_wednesday, 'Y', 1, 0) +
            DECODE(cmt.flag_thursday , 'Y', 1, 0) +
            DECODE(cmt.flag_friday   , 'Y', 1, 0)
        ) AS frequencia      
    FROM 
        cmx_studant cmt,
        cmx_incharge cmi,
        cmx_team cmte,
        cmx_class cmc
    WHERE 
            cmt.incharge_id = cmi.incharge_id
            AND cmt.team_id = cmte.team_id
            AND cmte.class_id = cmc.class_id
            AND cmt.FLAG_STATUS = 'A'
    GROUP BY 
        cmt.flag_status,
        cmt.rg_cpf,
        cmt.studant_id,
        cmt.tip_plano,
        cmt.plano,
        cmc.class_id,
        cmc.name,
        cmi.cpf,
        cmi.name,
        cmi.phone;

  --
  CURSOR c_preco(pc_tip_plano  cmx_preco.tip_plano %TYPE,
                 pc_plano      cmx_preco.plano     %TYPE,
                 pc_class_id   cmx_preco.class_id  %TYPE,
                 pc_frequencia cmx_preco.frequencia%TYPE)
     IS                 
     SELECT *
       FROM cmx_preco
      WHERE tip_plano  = pc_tip_plano
        AND plano      = pc_plano
        AND class_id   = pc_class_id
        AND frequencia = pc_frequencia
        AND ativo      = 'Y';
  --
  l_reg_fatura cmx_fatura%ROWTYPE;
  l_existi  number;
  l_reg_preco    cmx_preco%ROWTYPE;
  l_reg_erro     CMX_ERRO_LOG%ROWTYPE;
  --
BEGIN
  --
  pc_contador := 0;
  --
  DELETE FROM CMX_ERRO_LOG;
  --
  FOR l_reg IN c_dados_alunos_A LOOP
    --	     
    l_reg_fatura.ANO_MES             :=  to_number(pc_ano || pc_mes)                    		       ;
    l_reg_fatura.studant_id          :=  l_reg.studant_id                             			       ;
    l_reg_fatura.STATUS 	          :=  l_reg.flag_status                          			       ;
    l_reg_fatura.RG_CPF 	          :=  l_reg.rg_cpf                               			       ;
    l_reg_fatura.RESPONSAVEL         :=  l_reg.nome_responsavel                          	               ;
    l_reg_fatura.CPF  		          :=  l_reg.cpf_responsavel                      			       ;
    l_reg_fatura.TELEFONE            :=  l_reg.phone                            			       ;
    l_reg_fatura.CLASS_ID            :=  l_reg.class_id                                			       ;
    l_reg_fatura.TIP_PLANO           :=  l_reg.tip_plano                        			       ;
    l_reg_fatura.PLANO	             :=  l_reg.plano                            			       ;
    ---------------
    IF c_preco%ISOPEN THEN
      --
      CLOSE c_preco;
      --
    END IF;
    --
    OPEN c_preco(pc_tip_plano => l_reg.TIP_PLANO,
                pc_plano      => l_reg.PLANO    ,
                pc_class_id   => l_reg.class_id ,
                pc_frequencia => l_reg.frequencia);
    -- 
    FETCH c_preco INTO l_reg_preco;
    --
    ---------------
    l_reg_fatura.FREQUENCIA          :=  l_reg.frequencia                       			       ;
    l_reg_fatura.VALOR_FATURA        :=  l_reg_preco.valor                                                     ;
    l_reg_fatura.DT_FATURA           :=  TO_CHAR(TO_DATE('15' || pc_mes || pc_ano,'DD/MM/YYYY'),'DD/MM/YYYY')  ;
    l_reg_fatura.DT_GEROU_FAT        :=  TO_CHAR(SYSDATE,'DD/MM/YYYY')                                         ;      
    --         
     select count(1)
       into l_existi
      FROM CMX_FATURA 
     WHERE ANO_MES      = l_reg_fatura.ANO_MES
     AND   studant_id   = l_reg_fatura.studant_id; 
    --
    IF l_existi = 0 THEN
      -- 
      IF l_reg_preco.valor IS NULL THEN
        --
        l_reg_erro.class_id           := l_reg.class_id  ;
	l_reg_erro.tip_plano	      := l_reg.tip_plano ;
	l_reg_erro.plano              := l_reg.plano	 ;
	l_reg_erro.frequencia	      := l_reg.frequencia;
        l_reg_erro.mensagem           := 'Preço não cadastrada! ';
        --
        INSERT INTO CMX_ERRO_LOG VALUES l_reg_erro;
        --
      ELSE
        --       
        pc_contador := pc_contador + 1;  
        --
        INSERT INTO  CMX_FATURA VALUES l_reg_fatura;
        --
      END IF;
      --
    END IF;
      --
      COMMIT;
      --
  END LOOP;
  --
END CMX_PROC_FATURA;
/