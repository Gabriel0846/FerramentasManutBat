#!/bin/bash

# ==========================================
# 1. SUDO AUTOMÁTICO
# ==========================================
if [ "$EUID" -ne 0 ]; then
  exec sudo -s "$0" "$@"
fi

# ==========================================
# 2. FUNÇÃO: RESET ANYDESK
# ==========================================
reset_anydesk() {
    local confirm
    confirm=$(dialog --stdout --clear --title "RESET ANYDESK" \
        --yesno "Isso apaga as configurações do AnyDesk e força um novo ID.\n\nContinuar?" 0 0)

    if [ $? -ne 0 ]; then
        return
    fi

    dialog --stdout --clear --title "RESET ANYDESK" \
        --infobox "Parando o serviço do AnyDesk..." 0 0
    systemctl stop anydesk 2>/dev/null

    dialog --stdout --clear --title "RESET ANYDESK" \
        --infobox "Removendo arquivos de configuração..." 0 0
    rm -rf /etc/anydesk 2>/dev/null
    rm -rf /root/.anydesk 2>/dev/null
    if [ -n "$SUDO_USER" ]; then
        local user_home
        user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        [ -n "$user_home" ] && rm -rf "$user_home/.anydesk" 2>/dev/null
    fi

    dialog --stdout --clear --title "RESET ANYDESK" \
        --infobox "Iniciando o serviço do AnyDesk..." 0 0
    systemctl start anydesk 2>/dev/null

    dialog --msgbox "Reset concluído.\n\nAbra o AnyDesk e verifique o novo ID." 0 0
}

# ==========================================
# 3. SUBMENU: APLICATIVOS
# ==========================================
menu_aplicativos() {
    while true; do
        local opcao
        opcao=$(dialog --stdout --clear --title "APLICATIVOS" \
            --menu "Escolha uma opção:" 0 0 0 \
            1 "RESET ANYDESK" \
            2 "Voltar")

        [ $? -ne 0 ] && break

        case "$opcao" in
            1) reset_anydesk ;;
            2) break ;;
        esac
    done
}

# ==========================================
# 4. MENU PRINCIPAL
# ==========================================
while true; do
    local opcao
    opcao=$(dialog --stdout --clear --title "MULTIFERRAMENTAS" \
        --menu "Escolha uma categoria:" 0 0 0 \
        1 "APLICATIVOS" \
        2 "Sair")

    [ $? -ne 0 ] && { clear; exit 0; }

    case "$opcao" in
        1) menu_aplicativos ;;
        2) clear; exit 0 ;;
    esac
done