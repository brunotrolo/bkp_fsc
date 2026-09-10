import { LightningElement, api } from 'lwc';

/** Próximos passos — tarefas; baixa é estado local. Sem eventos. */
export default class Visao360Tarefas extends LightningElement {
    @api tarefas = [];

    concluidas = [];

    get temTarefas() {
        return (this.tarefas?.length ?? 0) > 0;
    }

    get tarefasEstado() {
        return (this.tarefas ?? []).map((t) => ({
            ...t,
            concluida: t.concluida || this.concluidas.includes(t.id)
        }));
    }

    aoAlternarTarefa(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        this.concluidas = event.target?.checked
            ? [...this.concluidas, id]
            : this.concluidas.filter((c) => c !== id);
    }
}
