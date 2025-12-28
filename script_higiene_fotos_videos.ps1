chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ========== Fondo clásico azul oscuro, texto blanco ==========
# ========== borrar en caso de error =========
$Host.UI.RawUI.BackgroundColor = "DarkBlue"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host
# ============================================================



# ===== AUMENTAR BUFFER DE PANTALLA A 10.000 LÍNEAS (SOLO ESTA SESIÓN) =====
try {
    $rawUI = $Host.UI.RawUI
    $bufferSize = $rawUI.BufferSize
    $windowSize = $rawUI.WindowSize

    $rawUI.BufferSize = New-Object Management.Automation.Host.Size (
        $bufferSize.Width,
        10000
    )

    if ($windowSize.Height -gt 60) {
        $rawUI.WindowSize = New-Object Management.Automation.Host.Size (
            $windowSize.Width,
            60
        )
    }
}
catch {}

# ============================================================
# ===================== FUNCIONES ============================
# ============================================================

function Mostrar-Leyenda {
    Write-Host "===================================================" -ForegroundColor White
    Write-Host "                 BUSCADOR DE ARCHIVOS" -ForegroundColor White
    Write-Host "                NO MULTIMEDIA CON RIESGO" -ForegroundColor White
    Write-Host "===================================================" -ForegroundColor White
    Write-Host ""
    Write-Host "LEYENDA DE RIESGO:" -ForegroundColor White
    Write-Host " ALTO        (.exe .msi .scr .ps1 .vbs .js .bat .cmd .com .pif)" -BackgroundColor DarkRed -ForegroundColor White
    Write-Host " MEDIO       (.docm .xlsm .pptm .lnk .html .htm .mhtml)"     -BackgroundColor DarkYellow -ForegroundColor Black
    Write-Host " MEDIO-BAJO  (.zip .rar .7z .iso .img .cab .dll)"           -BackgroundColor Yellow -ForegroundColor Black
    Write-Host " BAJO        (.swf)"                                       -BackgroundColor DarkMagenta -ForegroundColor White
    Write-Host " CRÍTICO     (doble extensión: .pdf.exe, etc)"             -BackgroundColor Black -ForegroundColor Red
    Write-Host "===================================================" -ForegroundColor White
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "===================================================" -ForegroundColor White
    Write-Host " Analiza archivos no multimedia, NO BORRA NADA." 
    Write-Host ""
    Write-Host "" 
    Write-Host " TENER EN CUENTA DE QUE AL ANALIZAR Y MOSTRAR EN"
    Write-Host " PANTALLA LOS RESULTADOS DE LOS ARCHIVOS QUE NO "
    Write-Host " SON IMAGENES O VIDEO, SOLO PODRÁ MOSTRAR UN TOTAL"
    Write-Host " DE 10.000 LINEAS, DE SER MÁS BORRA LOS RESULTADOS"
    Write-Host " DE LA BÚSQUEDA ANTIGUOS Y MUESTRA LOS NUEVOS, "
    Write-Host " QUEDANDO EN TOTAL, SIEMPRE EN PANTALLA 10.000"
    Write-Host " RESULTADOS."
    Write-Host ""
    Write-Host " SIGNIFICANDO ENTONCES QUE PROBABLEMENTE DEBAS EJECUTAR"
    Write-Host " VARIAS VECES EL SCRIPT SOBRE EL MISMO DIRECTORIO PARA MOSTRAR"
    Write-Host " LO QUE ANTES NO HABÍA MOSTRADO"
    Write-Host ""
    Write-Host " SUPONIENDO QUE HAS BORRADO O REDUCIDO ESOS ARCHIVOS, SI NO"
    Write-Host " ESTARIAS TODO EL RATO MOSTRANDO EL MISMO RESULTADO"
    Write-Host " PUES NO HAS MODIFICADO/ELIMINADO NADA"
    Write-Host ""
    Write-Host " ESO NO SIGNIFICA QUE BORRE NINGÚN ARCHIVO"
    Write-Host " SÓLO NO MUESTRA EN PANTALLA LOS RESULTADOS DE LA"
    Write-Host " BÚSQUEDA"
    Write-Host " EL SCRIPT BUSCA ARCHIVOS DIFERENTES A LOS QUE ESTÁN"
    Write-Host " PUESTOS DENTRO DE ESTE SCRIPT."
    Write-Host " DE NO SER ACORDE AL GUSTO, LO MODIFICAS."
    Write-Host "===================================================" -ForegroundColor White
}

# ================= PROGRAMA 1 =================
function Programa-Archivos-Riesgo {

    Clear-Host
    Mostrar-Leyenda

    while ($true) {

    	Write-Host ""
    	Write-Host ""
    	Write-Host "Introduce la ruta hacia una carpeta/directorio que vaya a ser analizada, escribela con espacios sin comillas"
    	Write-Host ""
    	Write-Host "Por ejemplo:" 
    	Write-Host "C:\Users\Usuario\Desktop"
    	Write-Host ""
    	Write-Host "y analizará todo el contenido de la carpeta raíz (Desktop) y sus subdirectorios/carpetas y carpetas de sus carpetas"
    	Write-Host ""
    	Write-Host ""
    	Write-Host ""
    	Write-Host "O escribe 'salir' para cerrar este programa de forma segura"
    	Write-Host ""




        $RutaBase = Read-Host "Ruta"

        if ($RutaBase.ToLower() -eq "salir") { break }

        if (-not (Test-Path $RutaBase)) {
            Write-Host "ERROR: La ruta no existe." -ForegroundColor Red
            continue
        }

        Clear-Host
        Mostrar-Leyenda

        Write-Host ""
        Write-Host "Analizando: $RutaBase"
        Write-Host ""

        $ExtExcluidas = @(
    	".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".webp",
    	".mp4", ".avi", ".mkv", ".mov", ".wmv", ".flv", ".mpeg", ".mpg", ".webm",
   	".mp3", ".wav", ".flac", ".aac", ".m4a",
   	".aae", ".thm",
   	".3gp", ".ogg", ".wma"
	)

        $Alto      = ".exe",".msi",".scr",".ps1",".vbs",".js",".bat",".cmd",".com",".pif"
        $Medio     = ".docm",".xlsm",".pptm",".lnk",".html",".htm",".mhtml"
        $MedioBajo = ".zip",".rar",".7z",".iso",".img",".cab",".dll"
        $Bajo      = ".swf"

        Get-ChildItem -Path $RutaBase -Recurse -File | Where-Object {
            $ExtExcluidas -notcontains $_.Extension.ToLower()
        } | ForEach-Object {

            $Nombre = $_.Name
            $Ruta   = $_.FullName
            $Ext    = $_.Extension.ToLower()

            if ($Nombre -match '\.[^\.]+\.(exe|scr|bat|cmd|ps1|vbs|js)$') {
                Write-Host $Ruta -BackgroundColor Black -ForegroundColor Red
            }
            elseif ($Alto -contains $Ext) {
                Write-Host $Ruta -BackgroundColor DarkRed -ForegroundColor White
            }
            elseif ($Medio -contains $Ext) {
                Write-Host $Ruta -BackgroundColor DarkYellow -ForegroundColor Black
            }
            elseif ($MedioBajo -contains $Ext) {
                Write-Host $Ruta -BackgroundColor Yellow -ForegroundColor Black
            }
            elseif ($Bajo -contains $Ext) {
                Write-Host $Ruta -BackgroundColor DarkMagenta -ForegroundColor White
            }
            else {
                Write-Host $Ruta
            }
        }

        Write-Host ""
        $c = Read-Host "¿Analizar otra ruta? (s/n)"
        if ($c.ToLower() -ne "s") { break }
        Clear-Host
        Mostrar-Leyenda
    }
}

# ================= PROGRAMA 2 =================
function Programa-Directorios-Vacios {

    Clear-Host
    Write-Host "==============================================="
    Write-Host "      BUSCADOR DE DIRECTORIOS VACÍOS"
    Write-Host "==============================================="
    Write-Host ""

    while ($true) {

        $RutaBase = Read-Host "Introduce la ruta (o 'salir')"

        if ($RutaBase.ToLower() -eq "salir") { break }

        if (-not (Test-Path $RutaBase)) {
            Write-Host "ERROR: La ruta no existe." -ForegroundColor Red
            continue
        }

        Write-Host ""
        Write-Host "Directorios vacíos encontrados:"
        Write-Host ""

        Get-ChildItem -Path $RutaBase -Recurse -Directory | Where-Object {
            @(Get-ChildItem $_.FullName -Force).Count -eq 0
        } | ForEach-Object {
            Write-Host $_.FullName -ForegroundColor Yellow
        }

        Write-Host ""
        $c = Read-Host "¿Analizar otra ruta? (s/n)"
        if ($c.ToLower() -ne "s") { break }
        Clear-Host
    }
}


# ================= PROGRAMA 3 =================
function Programa-Archivos-Y-Carpetas-Ocultas {

    Clear-Host
    Write-Host "==============================================="
    Write-Host "       BUSCADOR DE ARCHIVOS Y CARPETAS OCULTAS"
    Write-Host "==============================================="
    Write-Host ""

    while ($true) {

        $RutaBase = Read-Host "Introduce la ruta (o 'salir')"

        if ($RutaBase.ToLower() -eq "salir") { break }

        if (-not (Test-Path $RutaBase)) {
            Write-Host "ERROR: La ruta no existe." -ForegroundColor Red
            continue
        }

        Write-Host ""
        Write-Host "Directorios ocultos encontrados:"
        Write-Host ""

        # Directorios ocultos
        Get-ChildItem -Path $RutaBase -Recurse -Directory -Force | Where-Object {
            $_.Attributes -band [System.IO.FileAttributes]::Hidden
        } | ForEach-Object {
            Write-Host $_.FullName -BackgroundColor Red -ForegroundColor White
        }

        Write-Host ""
        Write-Host "Archivos ocultos encontrados:"
        Write-Host ""

        # Archivos ocultos
        Get-ChildItem -Path $RutaBase -Recurse -File -Force | Where-Object {
            $_.Attributes -band [System.IO.FileAttributes]::Hidden
        } | ForEach-Object {
            Write-Host $_.FullName -BackgroundColor DarkMagenta -ForegroundColor White
        }

        Write-Host ""
        $c = Read-Host "¿Analizar otra ruta? (s/n)"
        if ($c.ToLower() -ne "s") { break }
        Clear-Host
    }
}



# ================= PROGRAMA 4 =================

function Programa-Archivos-Duplicados {

    Clear-Host
    Write-Host "==============================================="
    Write-Host "           BUSCADOR DE ARCHIVOS DUPLICADOS"
    Write-Host "==============================================="
    Write-Host ""

    while ($true) {

        $RutaBase = Read-Host "Introduce la ruta (o 'salir')"

        if ($RutaBase.ToLower() -eq "salir") { break }

        if (-not (Test-Path $RutaBase)) {
            Write-Host "ERROR: La ruta no existe." -ForegroundColor Red
            continue
        }

        Write-Host ""
        Write-Host "Analizando archivos y calculando hashes..."
        Write-Host ""

        # Crear un diccionario para almacenar hashes y rutas
        $hashDict = @{}

        # Recorrer todos los archivos
        Get-ChildItem -Path $RutaBase -Recurse -File | ForEach-Object {
            try {
                $hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
                if ($hashDict.ContainsKey($hash)) {
                    $hashDict[$hash] += ,$_.FullName
                }
                else {
                    $hashDict[$hash] = @($_.FullName)
                }
            }
            catch {
                Write-Host "No se pudo calcular hash de: $($_.FullName)" -ForegroundColor Yellow
            }
        }

        Write-Host ""
        Write-Host "Archivos duplicados encontrados:" -ForegroundColor White
        Write-Host ""

        $duplicados = $hashDict.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

        if ($duplicados.Count -eq 0) {
            Write-Host "No se encontraron archivos duplicados en esta ruta." -ForegroundColor Green
        }
        else {
            foreach ($entry in $duplicados) {
                Write-Host "------ HASH: $($entry.Key) ------" -ForegroundColor Cyan
                foreach ($file in $entry.Value) {
                    Write-Host $file -ForegroundColor Red
                }
                Write-Host ""
            }
        }

        Write-Host ""
        $c = Read-Host "¿Analizar otra ruta? (s/n)"
        if ($c.ToLower() -ne "s") { break }
        Clear-Host
    }
}



# ============================================================
# ======================= MENÚ ===============================
# ============================================================

while ($true) {

    Clear-Host
    Write-Host "==============================================="
    Write-Host "           SELECCIÓN DE PROGRAMA"
    Write-Host "==============================================="
    Write-Host ""
    Write-Host "1) Buscar archivos NO multimedia con riesgo"
    Write-Host "2) Buscar directorios vacíos"
    Write-Host "3) Mostrar carpetas ocultas"
    Write-Host "4) Buscar archivos que se repiten, NO por nombre, si no, por contenido: mediante verificación de hash"
    Write-Host ""
    Write-Host "Escribe el número del programa o 'salir'"
    Write-Host ""

    $opcion = Read-Host "Opción"

    switch ($opcion) {
        "1" { Programa-Archivos-Riesgo }
        "2" { Programa-Directorios-Vacios }
   	"3" { Programa-Archivos-Y-Carpetas-Ocultas }
   	"4" { Programa-Archivos-Duplicados }

        "salir" { break }
        default {
            Write-Host "Opción no válida." -ForegroundColor Red
            Start-Sleep 2
        }
    }
}
