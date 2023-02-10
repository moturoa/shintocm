
library(shintodb)
library(DBI)
library(dplyr)

.cm <- contentManager$new("Demo", schema = "wonmon")

.cm$list_keys()
.cm$list_keys(include_deleted = TRUE)

.cm$set("tooltip_aantalwoningen", "Aantal woningen in het project")

.cm$set("tooltip_huurkoop", "huur of koop")
.cm$set("tooltip_huurkoop", "huur of koopof toch wat andr")

.cm$get("tooltip_aantalwoningen")

.cm$delete("tooltip_aantalwoningen")

.cm$close()

