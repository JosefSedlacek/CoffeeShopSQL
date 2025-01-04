# CoffeeShopSQL
Tento projekt jsem vytvořil jako cvičení v rámci kurzu zaměřeného na SQL. Dostali jsme data nově otevřených kaváren v NewYorku a otázky, na které jsme měli odpovědět. Po zpracování dat pomocí SQL dotazů jsem stejná data použil i na vytvoření PowerBI dashboardu, který poskytuje odpovědi na všechny otázky ze zadání.

## Zadání
Máte k dispozici data Coffee_Shop_Data.csv. Tyto data uložte do databáze.  
Vytvořte si tabulku, kterou budete následně analyzovat pomocí SQL dotazů.  

Soubor obsahuje následující informace:
* ``transaction_id`` - unikátní číslo transakce
* ``transaction_date`` - datum proběhlé transakce
* ``transaction_time`` - čas proběhlé transakce
* ``transaction_qty`` - množství položek zahrnutých v transakci
* ``store_id`` - unikátní číslo prodejny
* ``store_location`` - lokace prodejny
* ``product_id`` - unikátní číslo produktu
* ``unit_price`` - cena jednoho kusu produktu
* ``product_category`` - kategorie produktu
* ``product_type`` - typ produktu (podkategorie)
* ``product_detail`` - detailní popis prodávaného produktu

## Otázky
Vaše analýza dat by měla zodpovědět následující otázky:
1. Celkové tržby za květen
2. Procentuální změna tržeb oproti dubnu
3. Celkový počet objednávek za květen
4. Procentuální změna počtu objednávek oproti dubnu
5. Celkový počet prodaných kusů produktů
6. Procentuální změna prodaných kusů oproti dubnu
7. Prodeje o svátku 27. května (USA)
8. Zobrazit průměrné tržby za květen
9. Zobrazit průměrné tržby za květen
10. Pro každý den určit, zda jsou tržby nad nebo pod průměrem
11. Porovnat tržby za pracovní dny versus víkendy
12. Zjistit tržby podle prodejny
13. Jaké kategorie produktů se prodávají nejlépe
14. Jaké konkrétní produkty se prodávají nejlépe
15. Zjistit, který den je nejvýdělečnější
16. Zjistit, které hodiny jsou nejvýdělečnější
