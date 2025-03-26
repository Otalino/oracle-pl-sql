create or replace PROCEDURE CMX_ATUALIZAR_VALOR( P_CLASS_ID      IN CMX_PRECO.CLASS_ID%TYPE  ,
                                                 P_TIP_PLANO     IN CMX_PRECO.TIP_PLANO%TYPE ,
                                                 P_PLANO         IN CMX_PRECO.PLANO%TYPE     ,
                                                 P_FREQUENCIA    IN CMX_PRECO.FREQUENCIA%TYPE,
                                                 P_OPERACAO      IN VARCHAR                  ,
                                                 P_NOVO_VALOR    IN NUMBER                   ,
                                                 P_CONTATOR      OUT NUMBER                  )
   IS
     --
     CURSOR C_VALOR 
     IS 
     SELECT ID_PRECO
          , VALOR
       FROM CMX_PRECO
      WHERE CLASS_ID   = nvl(P_CLASS_ID  , CLASS_ID  )
        AND TIP_PLANO  = nvl(P_TIP_PLANO , TIP_PLANO )
        AND PLANO      = nvl(P_PLANO     , PLANO     ) 
        AND FREQUENCIA = nvl(P_FREQUENCIA, FREQUENCIA);
     --
  BEGIN
    --
    P_CONTATOR := 0;
    --
    FOR REG in C_VALOR LOOP 
        --
        IF P_OPERACAO = '-' THEN
          -- 
          UPDATE cmx_preco
             SET valor      = (REG.VALOR - P_NOVO_VALOR) 
           WHERE ID_PRECO   = REG.ID_PRECO;
          --
          P_CONTATOR := P_CONTATOR + 1;
          --
        ELSIF P_OPERACAO = '+' THEN
          --
          UPDATE cmx_preco
             SET valor      = (REG.VALOR + P_NOVO_VALOR) 
           WHERE ID_PRECO   = REG.ID_PRECO;
          --
          P_CONTATOR := P_CONTATOR + 1;
          --
        ELSIF P_OPERACAO = '%' THEN
          --
          UPDATE cmx_preco
             SET valor      = REG.VALOR + (REG.VALOR * P_NOVO_VALOR / 100)
           WHERE ID_PRECO   = REG.ID_PRECO;
          --
          P_CONTATOR := P_CONTATOR + 1;
         --
        END IF;
        --
        COMMIT;
        --
     END LOOP;
     --
  END CMX_ATUALIZAR_VALOR;
/