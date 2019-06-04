(memory_map fidelio_soc

  (parameters
      (bus
        (frequency 100)
        (address_size 8)
        (data_size 32)
      )

      (range 0x0 0xc)
  )

  (zone fidelio_ip
    (range 0x0 0x7)

    (register ram_address
      (address 0x0)
      (init 0x0)
      (bitfield 7..0
        (name value)
      )
    )

    (register ram_datain_b7_b0
      (address 0x1)
      (init 0x0)
    )

    (register ram_datain_b15_b8
      (address 0x2)
      (init 0x0)
    )

    (register ram_dataout
      (address 0x3)
      (init 0x0)
      (sampling true)
    )

    (register ram_control
      (address 0x4)
      (init 0x0)
      (bit 0
        (name we)
        (toggle true)
        (purpose "write to memory")
      )
      (bit 1
        (name en)
        (purpose "write")
        (toggle true)
      )
      (bit 2
        (name sreset)
        (purpose "reset all bram memory")
        (toggle true)
      )
      (bit 3
        (name mode)
        (purpose "mode 0 is access from UART")
      )
    )

    (register fsm_control
      (address 0x5)
      (init 0x0)
      (bit 0
        (name go)
        (purpose "run the FSM")
        (toggle true)
      )
    )

    (register fsm_status
      (address 0x6)
      (init 0x0)
      (sampling true)
      (bit 0
        (name completed)
      )
    )
  )
)
