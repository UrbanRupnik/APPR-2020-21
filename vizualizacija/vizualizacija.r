


# 1. graf: vrste dohodka

graf_vrste_dohodka <- ggplot(vrste_dohodka, aes(x=factor(Leto), y=Dohodek,group=Vrsta.dohodka, colour=Vrsta.dohodka)) + 
  geom_line(aes(colour=Vrsta.dohodka)) +
  geom_point(aes(colour=Vrsta.dohodka)) +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
  labs(title="Dohodek glede na vrsto", x="Leto", y = "Dohodek", colour="Vrsta dohodka")
print(graf_vrste_dohodka)


# 2. graf: delež vrste dohodka 2019

vrste_dohodka_19 <- vrste_dohodka %>%
  filter(Leto == 2019) %>%
  select(Vrsta.dohodka, Dohodek) %>%
  mutate(Delez19 = round((Dohodek/sum(Dohodek))*100, 0))

dohodek_19 <- vrste_dohodka_19 %>%
  select(Delez19) %>%
  unlist()

vrste_imena <- sprintf("%s (%s)", vrste_dohodka_19$Vrsta.dohodka, 
                       percent(round(vrste_dohodka_19$Dohodek/sum(vrste_dohodka_19$Dohodek), 2)))

names(dohodek_19) <- vrste_imena

graf_delez_vrste <- waffle(dohodek_19, rows = 6, title = "Delež dohodka glede na vrsto 2019")

print(graf_delez_vrste)

# 3. graf: razlika po spolu, (starost = skupaj)

graf_spol <- ggplot(spol, aes(x=factor(Leto), y=Dohodek, group=Spol)) +
  geom_line(aes(color=Spol)) +
  geom_point(aes(color=Spol)) +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
  labs(x="Leto", y = "Dohodek", fill="Leto")
print(graf_spol)

# 4. graf: razlika po spolu 2

razlika_spol <- spol %>%
  arrange(desc(Leto)) %>%
  pivot_wider(names_from = Spol, values_from = Dohodek) %>%
  mutate(Razlika = Moški - Ženske)

graf_razlika_spol <- ggplot(razlika_spol, aes(x=factor(Leto), y=Razlika, group=1)) +
  geom_line() +
  geom_point() +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
  labs(x="Leto", y = "Razlika dohodka")

print(graf_razlika_spol)

# 5. graf: Razlika med spoloma - skupaj
graf_spol_skupaj <- ggarrange(graf_spol, graf_razlika_spol, labels=c("Dohodek po spolu", "Razlika"),
                              common.legend = TRUE, legend = "bottom")
print(graf_spol_skupaj)

# 6. graf: izobrazba

izobrazba_spol_2 <- izobrazba_spol %>%
  mutate(Izobrazba2=Izobrazba, Spol2=Spol)


graf_izobrazba_spol <- ggplot(izobrazba_spol_2, aes(x=factor(Leto), y=Dohodek)) +
  geom_line(izobrazba_spol_2 %>% select(-Izobrazba, -Spol),
            mapping=aes(group=interaction(Spol2, Izobrazba2)), color="grey", size=0.5) +
  geom_line(aes(group=interaction(Spol, Izobrazba), color=Spol), size=1.2)+
  scale_color_manual(breaks=c("Moški", "Ženske"), values=c("#00BFC4", "#F8766D"))+
  theme_bw() +
  theme(plot.title = element_text(), panel.grid = element_blank()) +
  labs(title="Izobrazba in spol", x="Leto", y = "Dohodek") +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
  facet_wrap(~Izobrazba)

print(graf_izobrazba_spol)


#7. graf: starost
starost_spol_2 <- starost_spol %>%
  mutate(Starost2=Starost, Spol2=Spol)


graf_starost_spol <- ggplot(starost_spol_2, aes(x=factor(Leto), y=Dohodek)) +
  geom_line(starost_spol_2 %>% select(-Starost, -Spol), 
            mapping=aes(group=interaction(Spol2, Starost2)), color="grey", size=0.5) +
  geom_line(aes(group=interaction(Spol, Starost), color=Spol), size=1.2)+
  scale_color_manual(breaks=c("Moški", "Ženske"), values=c("#00BFC4", "#F8766D"))+
  theme_bw() +
  theme(plot.title = element_text(), panel.grid = element_blank()) +
  labs(title="Starost in spol", x="Leto", y = "Dohodek") +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
  facet_wrap(~Starost)

print(graf_starost_spol)


# Zemljevid statističnih regij

zemljevid_regije <- uvozi.zemljevid("https://biogeo.ucdavis.edu/data/gadm3.6/shp/gadm36_SVN_shp.zip",
                                    "gadm36_SVN_1", encoding = "UTF-8")

zemljevid_regije$NAME_1 <- as.factor(iconv(as.character(zemljevid_regije$NAME_1),
                                           "UTF-8"))

#Spodnjeposavska = Posavska
#Notranjsko-kraška = Primorsko-notranjska

levels(zemljevid_regije$NAME_1)[levels(zemljevid_regije$NAME_1)=="Spodnjeposavska"] <- "Posavska"
levels(zemljevid_regije$NAME_1)[levels(zemljevid_regije$NAME_1)=="Notranjsko-kraška"] <- "Primorsko-notranjska"

regije_8_19 <- regije %>%
  select(Regija, Leto, Dohodek) %>%
  filter(Leto %in% c(2008, 2019)) %>%
  pivot_wider(names_from = Leto, values_from = Dohodek) %>%
  mutate(Rast = (((`2019` - `2008`) / `2008`) * 100))


narisi_zemljevid <- tm_shape(merge(zemljevid_regije, regije_8_19, by.x="NAME_1", by.y="Regija")) +
  tm_polygons(c("2008", "2019", "Rast") , style="cont", palette = "YlGn") +
  tm_layout(legend.position = c("right", "bottom"), 
            main.title = "Zemljevid razpoložljivega dohodka gospodinjstev") +
  tm_facets(sync = TRUE, ncol = 2)

print(narisi_zemljevid)


narisi_zemljevid_regije <- tm_shape(zemljevid_regije) +
  tm_polygons(col = "white") +
  tm_text("NAME_1", size = "AREA")
print(narisi_zemljevid_regije)


#zemljevid_skupaj <- tmap_arrange(narisi_zemljevid)
#
#print(zemljevid_skupaj)











