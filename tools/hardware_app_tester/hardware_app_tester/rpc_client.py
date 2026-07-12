"""Skeleton protobuf RPC client for screen-frame capture and safe input
injection, over the Flipper Zero's official RPC session
(the same protocol qFlipper itself uses, exposed on the same serial
port as the line CLI once an RPC session is opened with `start_rpc_session`).

STATUS: skeleton only. The Flipper Zero RPC protocol is defined by
`.proto` files in the upstream firmware's own
`applications/services/rpc/` and lacks a stable, versioned, standalone
package this tool can simply `pip install` - a real implementation needs
to vendor or generate Python stubs from the exact `.proto` set matching
the installed firmware's protocol version, which was out of scope for
this foundation phase. This module defines the intended interface and
the safety invariants any real implementation must preserve, so that
Part I's architecture is concrete even though the RPC transport itself
is not yet implemented or hardware-tested.

This module contains NO flash, update, repair, erase, or format request
type, and must never gain one - checked by
tests/test_no_destructive_capability.py.
"""

from __future__ import annotations

import dataclasses
from typing import List, Optional, Protocol

# Input keys this client is ever allowed to send. Deliberately excludes
# any concept of "hold for N seconds" combinations used to enter DFU
# mode, and excludes any GPIO/radio/emulation-specific message types -
# those live in entirely different RPC message families this client
# does not implement.
ALLOWED_INPUT_KEYS = frozenset({"UP", "DOWN", "LEFT", "RIGHT", "OK", "BACK"})


class RpcTransport(Protocol):  # pragma: no cover - structural typing only
    def send(self, message_bytes: bytes) -> None: ...

    def receive(self, timeout: float) -> Optional[bytes]:
        ...


@dataclasses.dataclass
class ScreenFrame:
    width: int
    height: int
    pixel_data: bytes  # 1bpp packed, matching the device's own framebuffer format
    captured_at_uptime_ms: int


class RpcInputRejected(RuntimeError):
    pass


class FlipperRpcClient:
    """Intended interface for the protobuf RPC session. Real message
    encoding/decoding against the firmware's compiled `.proto` schema is
    NOT implemented here - see module docstring. Every method below
    documents the safety invariant a real implementation must preserve.
    """

    def __init__(self, transport: RpcTransport):
        self._transport = transport

    def request_screen_frame(self, timeout: float = 2.0) -> ScreenFrame:
        """Must map to the RPC session's screen-streaming
        start/frame/stop request family only - never a request type that
        could trigger a write, emulation, or transmission side effect.
        """
        raise NotImplementedError(
            "RPC screen-frame capture is not implemented in this "
            "foundation phase - see module docstring."
        )

    def send_input(self, key: str, hold_ms: int = 0) -> None:
        """Sends a single directional/OK/BACK key press. Rejects any
        key not in ALLOWED_INPUT_KEYS, and rejects any hold duration
        long enough to be associated with a known device combo (e.g.
        entering DFU mode), regardless of key.
        """
        if key not in ALLOWED_INPUT_KEYS:
            raise RpcInputRejected(
                f"Refusing to send unrecognized/unsafe input key: {key!r}"
            )
        if hold_ms > 3000:
            raise RpcInputRejected(
                f"Refusing to send a hold duration of {hold_ms}ms - "
                "durations this long are associated with device mode-"
                "change button combinations, not app navigation."
            )
        raise NotImplementedError(
            "RPC input injection is not implemented in this foundation "
            "phase - see module docstring."
        )

    def send_input_sequence(self, keys: List[str]) -> None:
        for key in keys:
            self.send_input(key)
