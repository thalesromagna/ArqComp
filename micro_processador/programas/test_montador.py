import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import montador as m


def bits(palavra):
    s = format(palavra, "017b")
    return "_".join([s[0:4], s[4:7], s[7:10], s[10:17]])


class TesteCodificacao(unittest.TestCase):
    def test_rom_do_thales(self):
        fonte = """
            ld r3, 0
            ld r4, 0
            add r4, r3
            ld r6, 1
            add r3, r6
            cmpi r3, 29
            ble -4
            mov r5, r4
        """
        esperado = [
            "0001_011_000_0000000", "0001_100_000_0000000", "0011_100_011_0000000",
            "0001_110_000_0000001", "0011_011_110_0000000", "1000_011_000_0011101",
            "0101_000_000_1111100", "0010_101_100_0000000",
        ]
        prog = m.montar(fonte)
        self.assertEqual([bits(i.palavra) for i in prog], esperado)

    def test_novas_instrucoes(self):
        prog = m.montar("lw r1, (r2)\nsw r5, (r7)\ninc r3\nhalt\nnop\njmp 9\nbvc -1\nsubb r0, r6\ncmpr r2, r3\nsub r1, r1\n.word 0x1DC81")
        self.assertEqual([bits(i.palavra) for i in prog], [
            "1010_001_010_0000000", "1011_101_111_0000000", "1100_011_000_0000000",
            "1101_000_000_0000000", "0000_000_000_0000000", "1111_000_000_0001001",
            "0110_000_000_1111111", "1001_000_110_0000000", "0111_010_011_0000000",
            "0100_001_001_0000000", "1110_111_001_0000001",
        ])

    def test_rotulos(self):
        prog = m.montar("inicio: ld r1, 1\nvolta:\n  inc r1\n  ble volta\n  jmp fim\n  nop\nfim: halt")
        self.assertEqual(bits(prog[2].palavra), "0101_000_000_1111111")
        self.assertEqual(bits(prog[3].palavra), "1111_000_000_0000101")
        self.assertEqual(prog[2].texto, "ble -1")
        self.assertEqual(prog[3].texto, "jmp 5")

    def test_limites(self):
        m.montar("ld r1, -64\nld r1, 63\ncmpi r1, -64")
        for ruim in ["ld r1, 64", "ld r1, -65", "cmpi r2, 100", "jmp 128", "jmp -1",
                     "ble 64", "ble -65", "ld r8, 1", "foo r1", "add r1", "ble nada"]:
            with self.assertRaises(m.ErroMontagem, msg=ruim):
                m.montar(ruim)
        with self.assertRaises(m.ErroMontagem):
            m.montar("nop\n" * 129)
        with self.assertRaises(m.ErroMontagem):
            m.montar("a: nop\nb: nop\nble x\nx: nop\n" + "nop\n" * 70 + "ble a")
        with self.assertRaises(m.ErroMontagem):
            m.montar("a: nop\na: nop")

    def test_vhd_formato(self):
        prog = m.montar("ld r3, 0\nble -4")
        vhd = m.gerar_vhd(prog)
        self.assertIn('        0 => B"0001_011_000_0000000", -- ld r3, 0', vhd)
        self.assertIn('        1 => B"0101_000_000_1111100", -- ble -4', vhd)
        self.assertIn("entity rom is", vhd)
        self.assertIn("rising_edge(clk)", vhd)
        self.assertEqual(m.ler_vhd(vhd), [prog[0].palavra, prog[1].palavra])


class TesteSimulador(unittest.TestCase):
    def rodar(self, fonte):
        return m.simular([i.palavra for i in m.montar(fonte)])

    def test_flags_sub_emprestimo(self):
        r = self.rodar("ld r1, 3\nld r2, 8\nsub r1, r2\nhalt")
        self.assertEqual(r.regs[1], 0xFFFB)
        self.assertEqual((r.z, r.n, r.c, r.v), (0, 1, 1, 0))

    def test_subb_usa_carry(self):
        r = self.rodar("ld r4, 3\nld r5, 8\nsub r4, r5\nld r6, 20\nld r0, 6\nsubb r6, r0\nmov r1, r6\nsubb r6, r0\nhalt")
        self.assertEqual(r.regs[1], 13)
        self.assertEqual(r.regs[6], 7)
        self.assertEqual(r.c, 0)

    def test_subb_overflow_como_ula(self):
        r = self.rodar("ld r1, 0\nld r2, -1\nld r3, 1\nld r4, 2\nsub r3, r4\nld r5, 1\nld r6, -64\nsubb r5, r6\nhalt")
        self.assertEqual(r.regs[5], 64)
        r = self.rodar("ld r1, -64\nld r2, -64\nadd r1, r2\nadd r1, r1\nadd r1, r1\nadd r1, r1\nadd r1, r1\nadd r1, r1\nadd r1, r1\nadd r1, r1\nadd r1, r1\nld r3, 1\nsub r1, r3\nhalt")
        self.assertEqual(r.regs[1], 0x7FFF)
        self.assertEqual(r.v, 1)

    def test_add_overflow_e_carry(self):
        r = self.rodar("ld r5, -63\nd: add r5, r5\nbvc d\nhalt")
        self.assertEqual(r.regs[5], 1024)
        self.assertEqual((r.z, r.n, r.c, r.v), (0, 0, 1, 1))

    def test_inc_nao_altera_flags(self):
        r = self.rodar("ld r1, 7\ncmpi r1, 7\ninc r1\nhalt")
        self.assertEqual(r.regs[1], 8)
        self.assertEqual(r.z, 1)

    def test_ble_e_bvc(self):
        r = self.rodar("ld r1, 5\ncmpi r1, 6\nble a\nld r7, -1\na: ld r7, 1\ncmpi r1, 4\nble b\nld r7, 2\nb: halt")
        self.assertEqual(r.saida_r7, [1, 2])

    def test_ram_e_r7(self):
        r = self.rodar("ld r1, 50\nadd r1, r1\nld r2, -9\nsw r2, (r1)\nld r2, 0\nlw r7, (r1)\nhalt")
        self.assertEqual(r.ram[100], 0xFFF7)
        self.assertEqual(r.saida_r7, [-9])

    def test_halt_conta_e_para(self):
        r = self.rodar("nop\nhalt\nld r7, 1")
        self.assertTrue(r.halt)
        self.assertEqual(r.instrucoes, 2)
        self.assertEqual(r.saida_r7, [])

    def test_opcode_1110_e_nop(self):
        r = self.rodar(".word 0x1DC81\nhalt")
        self.assertEqual(r.regs, [0] * 8)

    def test_salto_modulo_128(self):
        r = m.simular([m.montar("ble -2")[0].palavra] + [0] * 125 + [m.montar("halt")[0].palavra], max_passos=10)
        self.assertFalse(r.halt)
        r = m.simular([m.montar("cmpi r0, 0")[0].palavra, m.montar("ble -2")[0].palavra] + [0] * 125 + [m.montar("halt")[0].palavra])
        self.assertTrue(r.halt)
        self.assertEqual(r.pc, 127)

    def test_r7_repetido_eh_erro(self):
        with self.assertRaises(m.ErroSimulacao):
            self.rodar("ld r7, 3\nld r7, 3\nhalt")
        with self.assertRaises(m.ErroSimulacao):
            self.rodar("ld r7, 0\nhalt")

    def test_leitura_ram_nao_inicializada_eh_erro(self):
        with self.assertRaises(m.ErroSimulacao):
            self.rodar("ld r1, 5\nlw r2, (r1)\nhalt")

    def test_sem_halt_eh_erro(self):
        r = m.simular([0] * 128, max_passos=500)
        self.assertFalse(r.halt)


if __name__ == "__main__":
    unittest.main()
