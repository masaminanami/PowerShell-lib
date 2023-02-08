#
# Shared Memory
#

enum SharedMemoryTag {
    CloseChannel = -1
    NoData = 0
    DataAck = 0
    Int32
    Int64
    String
}

class SharedMemory {

    $name;
    $size;
    $mmf;
    $drv;
    $encoder;

    Create($n, $s) {
        $this.name = $n
        $this.size = $s
        $this.mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::CreateNew($this.name, $this.size)
        $this.init()
    }

    Open($n, $s) {
        $this.name = $n
        $this.size = $s
        $this.mmf = [System.IO.MemoryMappedFiles.MemoryMappedFile]::OpenExisting($this.name)
        $this.init()
    }

    Close() {
        if ($this.drv) {
            $this.drv.Dispose()
            $this.drv = $null
        }
        if ($this.mmf) {
            $this.mmf.Dispose()
            $this.mmf = $null
        }
    }

    init() {
        $this.drv = $this.mmf.CreateViewAccessor()
        $this.encoder = [System.Text.Encoding]::UTF8
    }

    SendClose() {
        $this.SendTag([SharedMemoryTag]::CloseChannel)
        $this.WaitAck()
        $this.Close()
    }

    SendInt32($n) {
        $this.drv.Write(2, [int32]$n)
        $this.SendTag([SharedMemoryTag]::Int32)
        $this.WaitAck()
    }

    SendInt64($n) {
        $this.drv.Write(2, [int64]$n)
        $this.SendTag([SharedMemoryTag]::Int64)
        $this.WaitAck()
    }

    SendString($s) {
        $bytes = $this.encoder.GetBytes($s)
        $this.drv.Write(2, [int16]$bytes.Count)
        $n = 4
        $bytes |%{ $this.drv.Write($n++, [byte]$_)}
        $this.SendTag([SharedMemoryTag]::String)
        $this.WaitAck()
    }

    SendTag($t) { $this.drv.Write(0, [int16]$t) }

    [Object] Get() {
        [SharedMemoryTag]$t = $this.GetTag()
        switch ($t) {
            ([SharedMemoryTag]::Int32) {
                $rc = $this.drv.ReadInt32(2);
                $this.SendAck()
                return ($t, [int32]$rc)
            }

            ([SharedMemoryTag]::Int64) {
                $rc = $this.drv.ReadInt64(2)
                $this.SendAck()
                return ($t, [int64]$rc)
            }

            ([SharedMemoryTag]::String) {
                $len = $this.drv.ReadInt16(2)
                if ($len) {
                    $bytes = 0 .. ($len-1) |%{ $this.drv.ReadByte(4+$_) }
                } else {
                    $bytes = @()
                }
                $this.SendAck()
                $rc = $this.encoder.GetString($bytes)
                return ($t, [string]$rc)
            }

            ([SharedMemoryTag]::CloseChannel) {
                return ($t, $null)
            }

            default {
                throw "ERROR! Unkown tagcode: $t"

            }
        }
        return $null
    }

    [SharedMemoryTag] GetTag() {
        while (($rc = $this.drv.ReadInt16(0)) -eq [SharedMemoryTag]::NoData) {
            logv "Waiting for next command..."
            Start-Sleep -s 2
        }
        return [SharedMemoryTag]$rc
    }

    SendAck() {
        $this.drv.Write(0, [int16][SharedMemoryTag]::NoData)
    }

    WaitAck() {
        $cnt = 0
        while (($t = $this.drv.ReadInt16(0)) -ne [SharedMemoryTag]::NoData) {
            logv "Waiting for receiver tag=$t,cnt=$cnt"
            $cnt++
            Start-Sleep -s 1
        }
    }
}