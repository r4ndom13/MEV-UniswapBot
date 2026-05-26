extends Node3D
class_name NivelBase

# Método único: faz a pausa final, fade para preto e avança ao próximo capítulo.
# Usar: await avancar()  ou  await avancar(1.5)  (demora em segundos antes do fade)
func avancar(demora: float = 0.5) -> void:
	if demora > 0.0:
		await get_tree().create_timer(demora).timeout
	await TransicaoManager.sumir(1.5)
	GameManager.proximo_nivel()
