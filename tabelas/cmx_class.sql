
  CREATE TABLE "CMX_CLASS" 
   (	"CLASS_ID" NUMBER NOT NULL ENABLE, 
	"NAME" VARCHAR2(200) NOT NULL ENABLE, 
	"CREATION_DATE" DATE, 
	"LAST_UPDATE_DATE" DATE, 
	 CONSTRAINT "CMX_CLASS_PK" PRIMARY KEY ("CLASS_ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "CMX_CLASS_UK" UNIQUE ("NAME")
  USING INDEX  ENABLE
   ) ;