chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms

function Select-File {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Todos los archivos (*.*)|*.*"
    if ($dialog.ShowDialog() -eq "OK") { return $dialog.FileName }
    return $null
}

function Select-Folder {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") { return $dialog.SelectedPath }
    return $null
}

function Save-Manifest {
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Filter = "Manifest SHA512 (*.sha512.manifest)|*.sha512.manifest"
    if ($dialog.ShowDialog() -eq "OK") { return $dialog.FileName }
    return $null
}

function Generate-Manifest {
    param ($TargetPath, $ManifestPath)
    "SHA512" | Set-Content $ManifestPath
    if (Test-Path $TargetPath -PathType Leaf) {
        Get-FileHash $TargetPath -Algorithm SHA512 |
        ForEach-Object { "$($TargetPath)|$($_.Hash)" } |
        Add-Content $ManifestPath
    }
    else {
        Get-ChildItem $TargetPath -Recurse -File |
        ForEach-Object {
            "$($_.FullName)|$((Get-FileHash $_.FullName -Algorithm SHA512).Hash)"
        } | Add-Content $ManifestPath
    }
    Write-Host "Manifiesto creado correctamente" -ForegroundColor Green

    Protect-Manifest $ManifestPath

}

function Protect-Manifest {
    param ($ManifestPath)

    # Quitar herencia
    icacls $ManifestPath /inheritance:r | Out-Null

    # Dar solo lectura al usuario actual
    icacls $ManifestPath /grant:r "$env:USERNAME:R" | Out-Null

    # Marcar como ReadOnly (extra)
    attrib +R $ManifestPath

    Write-Host "Manifiesto protegido (solo lectura)" -ForegroundColor DarkGreen
}

function Verify-Integrity {
    param ($ManifestPath)

    if (-not (Test-Path $ManifestPath)) {
        Write-Host "Manifiesto no encontrado" -ForegroundColor Red
        return
    }

    $manifestFiles = @{}
    $lines = Get-Content $ManifestPath | Select-Object -Skip 1

    foreach ($line in $lines) {
        $path, $hash = $line -split '\|'
        $manifestFiles[$path] = $hash
    }

    # Directorio base
    $baseDir = Split-Path ($manifestFiles.Keys | Select-Object -First 1) -Parent

    # Verificar archivos existentes
    foreach ($path in $manifestFiles.Keys) {
        if (-not (Test-Path $path)) {
            Write-Host "[ELIMINADO] $path" -ForegroundColor Yellow
        }
        elseif ((Get-FileHash $path -Algorithm SHA512).Hash -ne $manifestFiles[$path]) {
            Write-Host "[MODIFICADO] $path" -ForegroundColor Red
        }
        else {
            Write-Host "[OK] $path" -ForegroundColor Green
        }
    }

    # Detectar archivos NUEVOS
    Get-ChildItem $baseDir -Recurse -File | ForEach-Object {
        if (-not $manifestFiles.ContainsKey($_.FullName)) {
            Write-Host "[NUEVO] $($_.FullName)" -ForegroundColor Cyan
        }
    }
}

# ==================== INTRUSCCIONES =============================
function Show-Instructions {
    param ($Mode)

    Clear-Host

    if ($Mode -eq "1") {
        Write-Host "===== GENERAR MANIFIESTO DE INTEGRIDAD =====`n" -ForegroundColor Cyan
        Write-Host "Este es el primer paso para verificar la integridad de los archivos"
        Write-Host "Es decir, para saber si han sido modificados/corrompidos, de forma"
        Write-Host "Intencionado o no intencionada."
        Write-Host ""
        Write-Host ""
        Write-Host "Este paso DEBE SER SALTADO en caso de ya tener un archivo manifiesto."
        Write-Host "Y proceder con el paso 2. Que es el de verificar el manifiesto que ya"
        Write-Host "tendríamos que tener, con los archivos en el estado actual en el que estén"
        Write-Host ""
        Write-Host ""
        Write-Host "De esta forma se comprobará mediante comparación de: lo nuevo VS lo antiguo"
        Write-Host "Si ha sido modificado."
        Write-Host ""
        Write-Host ""
        Write-Host "Para resumir, este proceso genera un hash para cada archivo, no carpetas."
        Write-Host "Los hashes son una cadena aleatoria de números y letras, generada de manera puramente matemática"
        Write-Host "Es tan aleatoria que jamás podrían coincidir los hashes de dos archivos diferentes..."
        Write-Host ""
        Write-Host "Por ejemplo: el hash del libro del quijote VS el hash del libro de shakespeare... Jamás coincidirá"
        Write-Host "La aleatoriedad se base en el contenido de un archivo, es decir,"
        Write-Host "si tuvieramos dos archivos del libro del Quijote"
        Write-Host "Pues lógicamente, el hash sería el mismo, pues el Quijote no cambia, es el mismo libro."
        Write-Host "El Hash SÓLO se basa en el contenido de un archivo, NO en su nombre, metadatos, tamaño, ubicación."
        Write-Host ""
        Write-Host ""
        Write-Host "Entonces, todos estos hashes los almacena todos en un archivo llamado `"manifiesto`" "
        Write-Host "cuya extensión del archivo es `".sha512.manifest`", y cuyo algoritmo matemático es SHA-512"
        Write-Host ""
        Write-Host ""
        Write-Host "Este archivo NO puede ser modificado de manera fácil, requiere de conocimiento técnico. "
        Write-Host "Aunque se puede."
        Write-Host ""
        Write-Host "Finalmente, la auténtica linea de defensa está en las copias de seguridad."
        Write-Host "Aunque se corrompan archivos, y este programa que estés usando nos diga "
        Write-Host "que se han modificado o eliminado archivos, no podemos hacer nada para recuperarlos."
        Write-Host "Este programa NO recupera archivos, solo señala lo que falta y lo modificado."
        Write-Host "Eres tú quien tiene que recuperarlos."
        Write-Host ""
        Write-Host ""
        Write-Host "Pues una de las propiedades matemáticas además de la aleatoriedad por el contenido, es que este proceso es irreversible."
        Write-Host "Esto quiere decir que dado un hash `"a87n21masd8x12...`" jamás podrás obtener el archivo físico "
        Write-Host "dado ese mismo hash. Que por irónico que parezca, tu has generado ese hash del archivo."
        Write-Host ""
        Write-Host "Sencillamente es una función matemática tan compleja que imposibilita su reversabilidad y no por la incapacidad de nuestros"
        Write-Host "ordenadores actuales y/o a futuro, si no, porque está a propósito hecho así."
        Write-Host ""
        Write-Host "De no haber sido creada de esta manera la función matemática, habría brechas de seguridad de dos pares de cojones. Y la integridad y hashes"
        Write-Host "son los pilares actuales principales y fundamentales de la ciberseguridad, junto con otros pilares."
        Write-Host ""
        Write-Host ""
        Write-Host "Para ello, están las copias de seguridad, es prácticamente imposible que en varios discos duros se produzca"
        Write-Host "el mismo problema. Que se borre algo o se modifique algo."
        Write-Host "Eso quiere decir que cogeremos los archivos que nos faltan de las copias de seguridad y las añadiremos a donde nos falte."
        Write-Host ""
        Write-Host "✔ No borra archivos"
        Write-Host "✔ No modifica carpetas"
        Write-Host "✔ No envía información a ningún sitio`n"
        Write-Host ""
        Write-Host "Cuando continúes:"
        Write-Host "- Elegirás un archivo o una carpeta del que quieras generar el manifiesto (el archivo que recopila 1 o muchos hashes)."
        Write-Host "- Deberás elegir la ubicación donde se almacenará ese hash."
        Write-Host "- Se creará un archivo MANIFIESTO con hashes de manera automática."
        Write-Host "- Ese manifiesto se protegerá automáticamente`n"
        Write-Host "Si ya has leído todo, pulsa ENTER para continuar..." -ForegroundColor Yellow
        Read-Host
    }

    elseif ($Mode -eq "2") {
        Write-Host "===== VERIFICAR INTEGRIDAD DE ARCHIVOS =====`n" -ForegroundColor Cyan
        Write-Host "Este proceso compara los archivos actuales con el manifiesto guardado."
        Write-Host "El manifiesto es un archivo que contiene uno o muchos hashes (valores únicos generados a partir del contenido de cada archivo)."
        Write-Host "Cada hash representa el estado exacto del archivo en el momento de crear el manifiesto."
        Write-Host "Si un archivo cambia, se elimina o aparece uno nuevo, el programa lo detectará comparando su contenido con los hashes almacenados."
        Write-Host ""
        Write-Host "Qué se verifica:"
        Write-Host "- Contenido de los archivos" -ForegroundColor Cyan
        Write-Host "- Archivos eliminados" -ForegroundColor Yellow
        Write-Host "- Archivos nuevos" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Qué NO se verifica:"
        Write-Host "- Nombres de archivos" 
        Write-Host "- Ubicación o permisos del archivo"
        Write-Host "- Metadatos como fecha de creación o modificación"
        Write-Host ""
        Write-Host "Para leer la teoría completa, sal y pulsa 1 para ver la teoría, "
        Write-Host "SÓLO léela y sal de nuevo, para volver al programa 2"
        Write-Host ""
        Write-Host "Resultados posibles:"
        Write-Host "[OK]        Archivo sin cambios" -ForegroundColor Green
        Write-Host "[MODIFICADO] Archivo cambiado" -ForegroundColor Red
        Write-Host "[ELIMINADO] Archivo desaparecido" -ForegroundColor Yellow
        Write-Host "[NUEVO]     Archivo nuevo no registrado`n" -ForegroundColor Cyan
        Write-Host "✔ No borra nada"
        Write-Host "✔ No modifica nada"
        Write-Host "✔ Solo informa`n"
        Write-Host "Si ya has leído todo, pulsa ENTER para continuar..." -ForegroundColor Yellow
        Read-Host
    }
}
# ================================================================



do {
    Write-Host "`n===== FILE INTEGRITY CHECKER ====="
    Write-Host "1) Generar manifiesto"
    Write-Host "2) Verificar integridad"
    Write-Host "0) Salir"

    $option = Read-Host "Selecciona opción"

    switch ($option) {
        "1" {

            Show-Instructions "1"

            $mode = Read-Host "1 = Archivo | 2 = Carpeta"
            if ($mode -eq "1") { $target = Select-File }
            elseif ($mode -eq "2") { $target = Select-Folder }

            if (-not $target) { break }
            $manifest = Save-Manifest
            if (-not $manifest) { break }

            Generate-Manifest $target $manifest
        }

        "2" {
            Show-Instructions "2"

            $manifest = Select-File
            if ($manifest) { Verify-Integrity $manifest }
        }
    }
}

while ($option -ne "0")