# Problém minimalizace převýšení

Cesta k řešení je následujicí:

- `001 - create grid.R` vytvoří pravidelný grid kolem středu Prahy definovaný plochou buňky; grid obsahuje centroidy s idčkem + nadmořskou výškou
- `010 - create links.R` v gridu definovaném dle předchozího bodu vytvoří spojnice jako čáry
- `020 - create sfnetworks.R` nad gridem, včetně spojnic, vytvoří síť třídy `{sfnetworks}`
- `100 - proof of concept.R` nad objektem třídy sfnetworks spočte navigační problém
- `110 - performance plot.R` vykreslí hezký obrázek nad spočtenými cestami

Pro proof of concept jsou definovány dvě "standardní" cesty:

- ze Sparty na Slavii
- z [Matfyzu Karlín](https://www.mff.cuni.cz/cs/vnitrni-zalezitosti/budovy-a-arealy/karlin) na [Matfyz Albertov](https://www.mff.cuni.cz/cs/vnitrni-zalezitosti/budovy-a-arealy/karlov)

Je očekávaný stav, že cesty z bodu A do bodu B povedou rozhodující měrou korytem Vltavy; široko daleko není jiný terén s menším převýšením, nežli dokonale vodorovná hladina řeky.
