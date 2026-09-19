import Base

# Closed frozen named byte-list inventory. Numeric constants only; no codecs.
type ByteListAlias is Data:
  Transaction{}

def capacity(alias: ByteListAlias) -> Nat:
  match alias:
    case Transaction{}: U32.to_nat(1073741824)
